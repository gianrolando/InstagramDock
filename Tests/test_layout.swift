import Foundation
import JavaScriptCore

let context = JSContext()!
context.exceptionHandler = { _, error in
    print("JavaScript error:", error?.toString() ?? "unknown")
    exit(1)
}
context.evaluateScript("""
var location = {hostname:'www.instagram.com', pathname:'/'};
function getComputedStyle() { return {visibility:'visible'}; }
function rect(left, top, width, height) { return {left,top,width,height,right:left+width,bottom:top+height}; }
function element(label, bounds, parent) {
  const values={};
  return {
    textContent:label, children:[], parentElement:parent,
    getClientRects:()=>[1],
    getBoundingClientRect:()=>bounds,
    contains:function(other) { while(other) { if(other===this)return true; other=other.parentElement; } return false; },
    style:{getPropertyValue:name=>values[name]?.value || '', getPropertyPriority:name=>values[name]?.priority || '',
      setProperty:(name,value,priority)=>{values[name]={value,priority};}, removeProperty:name=>{delete values[name];}}
  };
}
var page=element('',rect(72,0,1377,1565),null);
var header=element('',rect(209,14,930,72),page);
var first=element('Per te',rect(209,57,45,18),header);
var second=element('Seguiti',rect(267,57,54,18),header);
var suggested=element('Suggeriti per te',rect(919,140,120,18),page);
var nodes=[first,second,suggested];
var document={documentElement:{},querySelectorAll:()=>nodes};
var window={addEventListener:()=>{}};
function MutationObserver() { this.observe=()=>{}; }
function setTimeout() {}
""")
context.evaluateScript(try String(contentsOfFile: CommandLine.arguments[1], encoding: .utf8))
let cases: [(String, String)] = [
    ("reported Italian header/sidebar geometry", "var r=window.__instagramDockAdjustLayout();r.state==='adjusted' && r.width===686 && header.style.getPropertyValue('max-width')==='686px'"),
    ("repeated mutations do not shrink the header", "window.__instagramDockAdjustLayout().width===686"),
    ("clips overflowing tab-strip descendants", "header.style.getPropertyValue('overflow-x')==='clip'"),
    ("English labels", "first.textContent='For you';second.textContent='Following';suggested.textContent='Suggested for you';window.__instagramDockAdjustLayout().state==='adjusted'"),
    ("narrow window without sidebar restores styles", "nodes=[first,second];window.__instagramDockAdjustLayout().state==='no-layout-match' && header.style.getPropertyValue('width')===''"),
    ("Direct pages are untouched", "nodes=[first,second,suggested];location.pathname='/direct/inbox/';window.__instagramDockAdjustLayout().state==='not-home' && header.style.getPropertyValue('max-width')===''"),
    ("already correct header is untouched", "location.pathname='/';var narrow=element('',rect(209,14,600,72),page);first.parentElement=narrow;second.parentElement=narrow;window.__instagramDockAdjustLayout().state==='no-overlap' && narrow.style.getPropertyValue('width')===''"),
    ("original inline declarations and priority survive restoration", "first.parentElement=header;second.parentElement=header;header.style.setProperty('width','90%','important');window.__instagramDockAdjustLayout();nodes=[];window.__instagramDockAdjustLayout();header.style.getPropertyValue('width')==='90%' && header.style.getPropertyPriority('width')==='important'"),
    ("profile page restores a previous adjustment", "nodes=[first,second,suggested];window.__instagramDockAdjustLayout();location.pathname='/some-account/';window.__instagramDockAdjustLayout().state==='not-home' && header.style.getPropertyValue('width')==='90%'"),
    ("missing feed tabs do not alter content", "location.pathname='/';nodes=[suggested];window.__instagramDockAdjustLayout().state==='no-layout-match'"),
    ("offscreen suggestion labels are ignored", "suggested.getClientRects=()=>[];nodes=[first,second,suggested];window.__instagramDockAdjustLayout().state==='no-layout-match'")
]
for (name, expression) in cases {
    guard context.evaluateScript(expression)?.toBool() == true else { print("FAIL:", name); exit(1) }
    print("PASS:", name)
}
