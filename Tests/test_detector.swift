import Foundation
import JavaScriptCore

let ctx = JSContext()!
ctx.exceptionHandler = { _, error in print("JS error:", error?.toString() ?? ""); exit(1) }
ctx.evaluateScript("""
var fixture = {links:[], labels:[], login:false};
var clock=1000; Date.now=()=>clock;
var location = {hostname:'www.instagram.com',origin:'https://www.instagram.com',pathname:'/',href:'https://www.instagram.com/'};
function URL(href, base) { this.origin='https://www.instagram.com'; this.pathname=href.replace('https://www.instagram.com',''); }
function getComputedStyle() { return {visibility:'visible'}; }
function element(text, label, children) { return {
  textContent:text || '', children:children || [], href:'https://www.instagram.com/direct/inbox/',
  getClientRects:()=>[1], getAttribute:function(name) { return name==='aria-label' ? label || '' : name==='aria-busy' && this.busy ? 'true' : ''; },
  querySelectorAll:function(selector) { return selector === '[aria-label]' ? this.children.filter(e=>e.getAttribute('aria-label')) : selector.includes('aria-busy') ? (this.busy ? [element('')] : []) : this.children; },
  closest:function() { return this.row || null; }
}; }
var document = {readyState:'complete',documentElement:{},querySelector:()=>fixture.login ? {} : null,
 querySelectorAll:(selector)=>selector === 'a[href]' ? fixture.links : selector === '[aria-label]' ? fixture.labels : fixture.busy ? [element('')] : []};
var window = {webkit:{messageHandlers:{badge:{postMessage:()=>{}}}}};
function MutationObserver() { this.observe=()=>{}; }
function setInterval() {} function setTimeout() {}
""")
let js = try String(contentsOfFile: CommandLine.arguments[1], encoding: .utf8)
ctx.evaluateScript(js)
let cases: [(String, String, String)] = [
    ("numeric badge", "fixture.links=[element('', '', [element('12')])];", "r.state==='known' && r.count===12 && !r.minimum"),
    ("minimum badge", "fixture.links=[element('', '', [element('99+')])];", "r.count===99 && r.minimum"),
    ("Italian accessibility label", "fixture.links=[element('', '3 messaggi non letti')];", "r.count===3"),
    ("English accessibility label", "fixture.links=[element('', '4 unread messages')];", "r.count===4"),
    ("wait before zero", "fixture.links=[element('Messaggi')];", "r.state==='settling'"),
    ("no title-based false count", "document.title='(9) Instagram';fixture.links=[];", "r.state==='unknown'"),
    ("indicator only", "fixture.links=[element('', 'Messaggi non letti')];", "r.state==='indicator'"),
    ("login", "fixture.login=true;", "r.state==='login'"),
    ("external origin", "location.hostname='example.com';", "r.state==='outside'"),
    ("deduplicate rows", "location.pathname='/direct/inbox/'; var row={};var a=element('', 'Unread');var b=element('', 'Non letto');a.row=row;b.row=row;fixture.labels=[a,b];", "r.state==='known' && r.count===1 && r.minimum")
]
for (name, setup, check) in cases {
    ctx.evaluateScript("fixture={links:[],labels:[],login:false};location.hostname='www.instagram.com';location.pathname='/';" + setup)
    let result = ctx.evaluateScript("var r=window.__instagramDockInspect(); " + check)!.toBool()
    if !result { print("FAIL: \(name)"); exit(1) }
    print("PASS: \(name)")
}
let transitions: [(String, String)] = [
 ("5 to 1 to zero", "fixture={links:[element('', '', [element('5')])],labels:[]};location.pathname='/';document.readyState='complete';clock=1000; window.__instagramDockInspect().count===5 && (fixture.links=[element('', '', [element('1')])],window.__instagramDockInspect().count===1) && (fixture.links=[element('Messaggi')],window.__instagramDockInspect().state==='settling') && (clock=10000,window.__instagramDockInspect().count===0)"),
 ("new unread cancels pending reset", "fixture.links=[element('Messaggi')];clock=11000;window.__instagramDockInspect();fixture.links=[element('', '', [element('2')])];window.__instagramDockInspect().count===2 && (fixture.links=[element('Messaggi')],clock=25000,window.__instagramDockInspect().state==='settling')"),
 ("loading prevents reset", "document.readyState='loading';clock=50000;window.__instagramDockInspect().state==='unknown'"),
 ("missing navigation prevents reset", "document.readyState='complete';fixture.links=[];clock=60000;window.__instagramDockInspect().state==='unknown'"),
 ("global spinner does not block reset", "fixture.links=[element('Messaggi')];fixture.busy=true;clock=70000;window.__instagramDockInspect().state==='settling' && (clock=80000,window.__instagramDockInspect().count===0)"),
 ("interactive page can reset", "document.readyState='interactive';fixture.busy=true;clock=90000;window.__instagramDockInspect().count===0"),
 ("Messages loading still prevents reset", "fixture.links[0].busy=true;window.__instagramDockInspect().state==='unknown'"),
 ("hidden stale label ignored", "fixture.busy=false;var hidden=element('', '1 unread message');hidden.getClientRects=()=>[];fixture.links=[element('', '', [hidden])];window.__instagramDockInspect().state==='settling'"),
 ("mark unread action ignored", "fixture.links=[element('Messaggi')];location.pathname='/direct/inbox/';var action=element('', 'Segna come non letto');action.row={};fixture.labels=[action];window.__instagramDockInspect().state==='settling'")
]
for (name, expression) in transitions {
 if ctx.evaluateScript(expression)?.toBool() != true { print("FAIL: \(name)");exit(1) }
 print("PASS: \(name)")
}
// Reproduce the supplied report: one Messages link, absent counter, a feed
// progress indicator, and the last confirmed unread count equal to one.
let reproduction = """
fixture={links:[element('', '', [element('1')])],labels:[],busy:true};
document.readyState='interactive';location.pathname='/';clock=100000;
var before=window.__instagramDockInspect();
fixture.links=[element('Messaggi')];
var during=window.__instagramDockInspect();clock=110000;
var after=window.__instagramDockInspect();
before.count===1 && during.state==='settling' && after.state==='known' && after.count===0 && after.pageLoadingIndicators===1;
"""
if ctx.evaluateScript(reproduction)?.toBool() != true { print("FAIL: supplied report regression");exit(1) }
print("PASS: supplied report regression (1 -> 0 with feed spinner)")
