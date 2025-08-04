const s=(n,d)=>r=>{const o=e=>{n==null||n(r,e)},t=()=>{d==null||d(r)};return{setupNode:e=>{e.node.addEventListener("dragstart",o),e.node.addEventListener("dragend",t)},tearDownNode:e=>{e.node.removeEventListener("dragstart",o),e.node.removeEventListener("dragend",t)}}};export{s};
//# sourceMappingURL=startAndEndEventsDNDPlugin-Bd5tQkcZ.js.map
