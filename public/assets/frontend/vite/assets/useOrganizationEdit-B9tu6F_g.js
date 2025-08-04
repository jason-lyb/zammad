import{b as u,i as l}from"./mobile-Bk4bKGxF.js";import{_ as c}from"./CommonShowMoreButton.vue_vue_type_script_setup_true_lang-0Icksle5.js";import{_ as g}from"./CommonUsersList.vue_vue_type_script_setup_true_lang-CKM-Z0cj.js";import{f as p,c as b,m as f,D as z,y as O,q as d,E as _,d as M}from"./vue-oicRkvo0.js";import{a$ as $,X as h,Y as D}from"./overviewAttributes.api-C09LSZ8O.js";import{q as i,r as U}from"./routes-CgLO9M4y.js";import{n as E}from"./vendor-C11O1Xx8.js";import{e as F}from"./apollo-Cj5TVUDk.js";const S=p({__name:"OrganizationMembersList",props:{organization:{},disableShowMore:{type:Boolean}},emits:["load-more"],setup(o,{emit:r}){const s=o,n=r,a=b(()=>{var e;return((e=s.organization.allMembers)==null?void 0:e.edges.map(({node:t})=>t))||[]});return(e,t)=>a.value.length?(f(),z(u,{key:0,"header-label":e.__("Members")},{default:O(()=>{var m;return[d(g,{users:a.value},null,8,["users"]),d(c,{entities:a.value,"total-count":((m=e.organization.allMembers)==null?void 0:m.totalCount)||0,disabled:e.disableShowMore,onClick:t[0]||(t[0]=C=>n("load-more"))},null,8,["entities","total-count","disabled"])]}),_:1},8,["header-label"])):_("",!0)}}),j=E`
    mutation organizationUpdate($id: ID!, $input: OrganizationInput!) {
  organizationUpdate(id: $id, input: $input) {
    organization {
      ...organizationAttributes
    }
    errors {
      ...errors
    }
  }
}
    ${$}
${h}`;function q(o={}){return F(j,o)}const x=()=>{const o=l("organization-edit",i.Organization),r=D([{name:"name",required:!0,screen:"edit",object:i.Organization},{screen:"edit",object:i.Organization},{name:"active",required:!0,screen:"edit",object:i.Organization}],{showDirtyMark:!0});return{openEditOrganizationDialog:async n=>{const a=M({domain:{required:!!n.domainAssignment},note:{props:{meta:{mentionText:{disabled:!0},mentionKnowledgeBase:{disabled:!0},mentionUser:{disabled:!0}}}}});o.openDialog({object:n,schema:r,mutation:q,formChangeFields:a,onChangedField:(e,t)=>{e==="domain_assignment"&&(a.domain.required=typeof t=="boolean"&&t||t==="true")},formUpdaterId:U.FormUpdaterUpdaterOrganizationEdit,errorNotificationMessage:__("Organization could not be updated.")})}}};export{S as _,x as u};
//# sourceMappingURL=useOrganizationEdit-B9tu6F_g.js.map
