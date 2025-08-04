import{u as _,Q as R}from"./apollo-Cj5TVUDk.js";import{f as $,k as A,d as x}from"./desktop-l0eJ1dZN.js";import{u as y,n as h}from"./vendor-C11O1Xx8.js";import{e as C}from"./routes-CgLO9M4y.js";import{f as w,c as m,a1 as L,m as k,p as B,q as b,y as g,H as f,D as T,I as D,E as v,u as V,r as z,s as Q}from"./vue-oicRkvo0.js";import{g as N}from"./getTicketNumber-CTSsSeKd.js";const I=w({__name:"TicketSimpleTable",props:{tickets:{},label:{},selectedTicketId:{}},emits:["click-ticket"],setup(s,{emit:l}){const n=l,{config:r}=y(C()),i=[{key:"state",label:"",truncate:!0,type:"link"},{key:"number",label:r.value.ticket_hook,type:"link",truncate:!0},{key:"title",label:__("Title"),truncate:!0},{key:"customer",label:__("Customer"),truncate:!0},{key:"group",label:__("Group"),truncate:!0},{key:"createdAt",label:__("Created at"),truncate:!0}],c=s,u=m(()=>c.tickets.map(e=>{var a,d,o;return{createdAt:e.createdAt,customer:((a=e.organization)==null?void 0:a.name)||((d=e.customer)==null?void 0:d.fullname),group:(o=e.group)==null?void 0:o.name,id:e.id,internalId:e.internalId,key:e.id,number:{link:`/tickets/${e.internalId}`,label:e.number,internal:!0},organization:e.organization,title:e.title,stateColorCode:e.stateColorCode,state:e.state}})),t=e=>{const a=c.tickets.find(d=>d.id===e.id);n("click-ticket",a)};return(e,a)=>{const d=L("CommonDateTime");return k(),B("section",null,[b(A,{ref:"simple-table",class:"w-full",caption:e.label,"show-caption":"",headers:i,items:u.value,"selected-row-id":e.selectedTicketId,onClickRow:t},{"column-cell-createdAt":g(({item:o,isRowSelected:p})=>[b(d,{class:f(["text-gray-100 group-hover:text-black group-focus-visible:text-white group-active:text-white dark:text-neutral-400 group-hover:dark:text-white group-active:dark:text-white",{"text-black dark:text-white":p}]),"date-time":o.createdAt,type:"absolute","absolute-format":"date"},null,8,["class","date-time"])]),"column-cell-state":g(({item:o,isRowSelected:p})=>[b($,{class:f(["shrink-0 group-hover:text-black group-focus-visible:text-white group-active:text-white group-hover:dark:text-white group-active:dark:text-white",{"ltr:text-black rtl:text-black dark:text-white":p}]),"color-code":o.stateColorCode,label:o.state.name,"aria-labelledby":o.id,"icon-size":"tiny"},null,8,["class","color-code","label","aria-labelledby"])]),_:1},8,["caption","items","selected-row-id"])])}}}),q=h`
    fragment simpleTicketAttribute on Ticket {
  number
  internalId
  id
  title
  customer {
    id
    fullname
  }
  organization {
    id
    name
  }
  group {
    id
    name
  }
  createdAt
  stateColorCode
  state {
    id
    name
  }
}
    `,H=h`
    query ticketRelationAndRecentTicketLists($ticketId: Int!, $customerId: ID!, $limit: Int) {
  ticketsRecentByCustomer(
    customerId: $customerId
    limit: $limit
    exceptTicketInternalId: $ticketId
  ) {
    ...simpleTicketAttribute
  }
  ticketsRecentlyViewed(exceptTicketInternalId: $ticketId, limit: $limit) {
    ...simpleTicketAttribute
  }
}
    ${q}`;function S(s,l={}){return _(H,s,l)}const E={class:"space-y-6"},J=w({__name:"TicketRelationAndRecentLists",props:{customerId:{},internalTicketId:{},selectedTicketId:{}},emits:["click-ticket"],setup(s){const l=s,n=new R(S({customerId:l.customerId,limit:10,ticketId:l.internalTicketId},{fetchPolicy:"cache-and-network"})),r=n.loading(),i=n.result(),c=m(()=>{var t;return(t=i.value)==null?void 0:t.ticketsRecentByCustomer}),u=m(()=>{var t;return(t=i.value)==null?void 0:t.ticketsRecentlyViewed});return(t,e)=>(k(),T(x,{loading:V(r)},{default:g(()=>[D("div",E,[c.value&&c.value.length>0?(k(),T(I,{key:0,label:t.$t("Recent Customer Tickets"),tickets:c.value,"selected-ticket-id":t.selectedTicketId,onClickTicket:e[0]||(e[0]=a=>t.$emit("click-ticket",a))},null,8,["label","tickets","selected-ticket-id"])):v("",!0),u.value&&u.value.length>0?(k(),T(I,{key:1,label:t.$t("Recently Viewed Tickets"),"selected-ticket-id":t.selectedTicketId,tickets:u.value,onClickTicket:e[1]||(e[1]=a=>t.$emit("click-ticket",a))},null,8,["label","selected-ticket-id","tickets"])):v("",!0)])]),_:1},8,["loading"]))}}),K=(s,l)=>{const{config:n}=y(C()),r=z(),i=Q(),c=m(()=>{if(i.value)return[{value:i.value.id,label:`${N(n.value.ticket_hook,i.value.number)} - ${i.value.title}`,heading:i.value.customer.fullname,ticket:i.value}]});return s("targetTicketId",t=>{var e;r.value=t??void 0,((e=i.value)==null?void 0:e.id)!==t&&(i.value=void 0)}),{formListTargetTicketOptions:c,targetTicketId:r,handleTicketClick:t=>{l({targetTicketId:t.id}),i.value=t}}};export{J as _,K as u};
//# sourceMappingURL=useTargetTicketOptions-Dw9uFPEv.js.map
