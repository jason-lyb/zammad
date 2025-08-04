import{az as Q,Z as v,aR as x}from"./overviewAttributes.api-C09LSZ8O.js";import{n as H}from"./vendor-C11O1Xx8.js";import{d as L,Q as $}from"./apollo-Cj5TVUDk.js";import{a3 as b}from"./vue-oicRkvo0.js";const q=H`
    query ticketSignature($groupId: ID!, $ticketId: ID) {
  ticketSignature(groupId: $groupId) {
    id
    renderedBody(ticketId: $ticketId)
  }
}
    `;function z(t,a={}){return L(q,t,a)}let o;const D=()=>o||(b().run(()=>{o=new $(z({groupId:""}))}),o),R=t=>{const a=D(),s=(i,u,c)=>u.name===c?u.newValue:i[c];return{signatureHandling:i=>{const u=(c,w,T)=>{var y,m,S;const{formNode:d,values:p,changedField:e}=T;if((e==null?void 0:e.name)!=="group_id"&&(e==null?void 0:e.name)!=="articleSenderType")return;const r=(y=d==null?void 0:d.find(i,"name"))==null?void 0:y.context;if(!r)return;const g=s(p,e,"group_id");if(!g){r.removeSignature();return}if(s(p,e,"articleSenderType")!=="email-out"){(m=r.removeSignature)==null||m.call(r);return}a.query({variables:{groupId:v("Group",String(g)),ticketId:(S=t==null?void 0:t.value)==null?void 0:S.id}}).then(({data:n})=>{var f,k;const I=(f=n==null?void 0:n.ticketSignature)==null?void 0:f.renderedBody,l=(k=n==null?void 0:n.ticketSignature)==null?void 0:k.id;if(!I||!l){r.removeSignature();return}r.addSignature({body:I,id:x(l)})})};return{execution:[Q.Initial,Q.FieldChange],callback:u}}}};export{D as g,R as u};
//# sourceMappingURL=useTicketSignature-LslYi6X7.js.map
