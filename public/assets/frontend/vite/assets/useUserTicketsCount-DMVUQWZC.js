import{i as f,X as h,Y as U}from"./overviewAttributes.api-C09LSZ8O.js";import{b,i as k}from"./mobile-Bk4bKGxF.js";import{_ as C}from"./CommonShowMoreButton.vue_vue_type_script_setup_true_lang-0Icksle5.js";import{f as z,a1 as D,m as s,D as u,y as p,p as $,x as w,q as g,I as y,M as E,J as F,E as I}from"./vue-oicRkvo0.js";import{U as M,q as l,e as j,r as B}from"./routes-CgLO9M4y.js";import{n as L}from"./vendor-C11O1Xx8.js";import{e as q}from"./apollo-Cj5TVUDk.js";const S={class:"truncate"},X=z({__name:"CommonOrganizationsList",props:{organizations:{},totalCount:{},disableShowMore:{type:Boolean,default:!1},label:{}},emits:["show-more"],setup(a,{emit:e}){const r=e;return(t,i)=>{const n=D("CommonLink");return t.organizations.length?(s(),u(b,{key:0,"header-label":t.label},{default:p(()=>[(s(!0),$(F,null,w(t.organizations,o=>(s(),u(n,{key:o.id,link:`/organizations/${o.internalId}`,class:"flex min-h-[66px] items-center"},{default:p(()=>[g(f,{entity:o,class:"ltr:mr-3 rtl:ml-3"},null,8,["entity"]),y("span",S,E(o.name),1)]),_:2},1032,["link"]))),128)),g(C,{entities:t.organizations,disabled:t.disableShowMore,"total-count":t.totalCount,onClick:i[0]||(i[0]=o=>r("show-more"))},null,8,["entities","disabled","total-count"])]),_:1},8,["header-label"])):I("",!0)}}}),A=L`
    mutation userUpdate($id: ID!, $input: UserInput!) {
  userUpdate(id: $id, input: $input) {
    user {
      ...userAttributes
    }
    errors {
      ...errors
    }
  }
}
    ${M}
${h}`;function N(a={}){return q(A,a)}const Y=()=>{const a=k("user-edit",l.User),e=U([{screen:"edit",object:l.User},{name:"active",required:!0,screen:"edit",object:l.User}],{showDirtyMark:!0}),r=j();return{openEditUserDialog:async i=>{const n={note:{props:{meta:{mentionText:{disabled:!0},mentionKnowledgeBase:{disabled:!0},mentionUser:{disabled:!0}}}},organization_id:{helpClass:""}};a.openDialog({object:i,mutation:N,schema:e,formChangeFields:n,onChangedField:(o,_)=>{var m;if(o==="organization_id"&&r.config.ticket_organization_reassignment){n.organization_id||(n.organization_id={});let d=__("Attention! Changing the organization will update the user's most recent tickets to the new organization."),c="text-yellow";((m=i.organization)==null?void 0:m.internalId)===_&&(d="",c=""),n.organization_id.help=d,n.organization_id.helpClass=c}},formUpdaterId:B.FormUpdaterUpdaterUserEdit,errorNotificationMessage:__("User could not be updated.")})}}},G=()=>({getTicketData:e=>!e||!e.ticketsCount?null:{count:e.ticketsCount,createLabel:__("Create new ticket for this user"),createLink:`/tickets/create?customer_id=${e.internalId}`,query:`customer.id: ${e.internalId}`}});export{X as _,G as a,Y as u};
//# sourceMappingURL=useUserTicketsCount-DMVUQWZC.js.map
