import{u as h}from"./useTicketView-CMOCBKg-.js";import{n as l}from"./vendor-C11O1Xx8.js";import{X as f}from"./overviewAttributes.api-C09LSZ8O.js";import{e as v,M as d}from"./apollo-Cj5TVUDk.js";import{a as k}from"./routes-CgLO9M4y.js";import{k as A}from"./lodash-pFOI14f-.js";import{c as u}from"./vue-oicRkvo0.js";const C=l`
    mutation mentionSubscribe($ticketId: ID!) {
  mentionSubscribe(objectId: $ticketId) {
    success
    errors {
      ...errors
    }
  }
}
    ${f}`;function j(r={}){return v(C,r)}const H=l`
    mutation mentionUnsubscribe($ticketId: ID!) {
  mentionUnsubscribe(objectId: $ticketId) {
    success
    errors {
      ...errors
    }
  }
}
    ${f}`;function L(r={}){return v(H,r)}const V=r=>{const{isTicketAgent:p}=h(r),M=u(()=>p.value),i=k(),o=e=>s=>{var t;const n=s;return!r.value||!n||((t=n.ticket)==null?void 0:t.id)!==r.value.id?n:{ticket:{...n.ticket,subscribed:e}}},c=new d(j({updateQueries:{ticket:o(!0)}})),a=new d(L({updateQueries:{ticket:o(!1)}})),b=u(()=>c.loading().value||a.loading().value),S=async e=>{var n;const s=await c.send({ticketId:e});return!!((n=s==null?void 0:s.mentionSubscribe)!=null&&n.success)},g=async e=>{var n;const s=await a.send({ticketId:e});return!!((n=s==null?void 0:s.mentionUnsubscribe)!=null&&n.success)},I=async()=>{if(!r.value||b.value)return!1;const{id:e,subscribed:s}=r.value;return s?g(e):S(e)},T=u(()=>{var e;return!!((e=r.value)!=null&&e.subscribed)}),U=u(()=>{var e,s,n;return((n=(s=(e=r.value)==null?void 0:e.mentions)==null?void 0:s.edges)==null?void 0:n.filter(({node:t})=>t.user.active).map(({node:t})=>({user:t.user,access:t.userTicketAccess})))||[]}),$=u(()=>{var e,s,n;return((n=(s=(e=r.value)==null?void 0:e.mentions)==null?void 0:s.edges)==null?void 0:n.filter(({node:t})=>t.user.id!==i.userId).map(({node:t})=>t.user))||[]}),w=u(()=>{var e,s,n;return A(((n=(s=(e=r.value)==null?void 0:e.mentions)==null?void 0:s.edges)==null?void 0:n.filter(({node:t})=>t.user.id!==i.userId).map(({node:t})=>({userId:t.user.id,access:t.userTicketAccess})))||[],"userId")}),m=u(()=>{var e;return(e=r.value)!=null&&e.mentions?r.value.mentions.edges.some(({node:s})=>s.user.id===i.userId):!1}),y=u(()=>{var e;return(e=r.value)!=null&&e.mentions?r.value.mentions.totalCount:0}),D=u(()=>{var e;return(e=r.value)!=null&&e.mentions?r.value.mentions.totalCount-(m.value?1:0):0});return{isSubscriptionLoading:b,isSubscribed:T,toggleSubscribe:I,canManageSubscription:M,subscribers:U,totalSubscribers:y,subscribersWithoutMe:$,subscribersAccessLookup:w,totalSubscribersWithoutMe:D,hasMe:m}};export{V as u};
//# sourceMappingURL=useTicketSubscribe-CmWzZx1x.js.map
