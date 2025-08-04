import{f as L,ab as I,a7 as T,r as D,w as R,a1 as O,m as c,p as b,I as p,M as v,J as E,x as Q,q as m,y as n,Q as f,D as h,E as y,aX as S,L as x,u as k}from"./vue-oicRkvo0.js";import{e as N,u as z,Q as V,M as U,N as $,c as q}from"./apollo-Cj5TVUDk.js";import{X as B,a2 as P}from"./overviewAttributes.api-C09LSZ8O.js";import{c as A,d as F}from"./desktop-l0eJ1dZN.js";import{a as H}from"./LayoutContent.vue_vue_type_script_setup_true_lang-SafgfcNL.js";import{n as g}from"./vendor-C11O1Xx8.js";import{d as X,a as Z,p as J}from"./index-DwuY2HL4.js";import{s as j}from"./startAndEndEventsDNDPlugin-Bd5tQkcZ.js";import{b as G,a as M}from"./lodash-pFOI14f-.js";import{u as K}from"./useBreadcrumb-DUhE6wbZ.js";import"./routes-CgLO9M4y.js";import"./vite-FJshFMF2.js";import"./formkit-5nol1GBe.js";import"./Form.vue_vue_type_script_setup_true_lang-B6L-6HzY.js";import"./FormGroup.vue_vue_type_script_setup_true_lang-DIx-HUKU.js";import"./useForm-CUKec4n5.js";import"./useCopyToClipboard-CjkPg__g.js";import"./theme-Bv2ClBzZ.js";import"./datepicker-BBNcWeHz.js";import"./date-B2UyDZN7.js";import"./autocompleteTags.api-CG5-cm_A.js";import"./autocompleteSearchTicket.api-DfOQWGlO.js";import"./ticketUpdates.api-BhGIG_Ti.js";import"./ticketAttributes.api-rqx5ITab.js";import"./useTicketCreateArticleType-D7iVcJ_6.js";import"./types-Cu-Nkl7K.js";import"./useTicketCreateView-HCH46SPv.js";import"./commonjsHelpers-BosuxZz1.js";import"./LayoutMain.vue_vue_type_script_setup_true_lang-DIWzj6-0.js";import"./LayoutSidebar.vue_vue_type_script_setup_true_lang-BO1pkKrb.js";import"./useResizeGridColumns-CieKHty_.js";const W=g`
    subscription userCurrentOverviewOrderingUpdates($ignoreUserConditions: Boolean!) {
  userCurrentOverviewOrderingUpdates(ignoreUserConditions: $ignoreUserConditions) {
    overviews {
      id
      name
      organizationShared
      outOfOffice
    }
  }
}
    `,Y={key:0,class:"rounded-lg bg-blue-200 dark:bg-gray-700"},ee={id:"drag-and-drop-ticket-overviews",class:"sr-only"},re={ref:"dnd-parent",class:"flex flex-col p-1"},te={class:"grow"},oe=L({__name:"PersonalSettingOverviewOrder",props:{modelValue:{required:!0},modelModifiers:{}},emits:["update:modelValue"],setup(s){const i=I(s,"modelValue"),a=r=>{const l=J.get(r);l&&(i.value=M(l.getValues(r)))},d=T("dnd-parent"),u=D(i.value||[]);return R(i,r=>{G(u.value,r)||(u.value=M(r||[]))}),X({parent:d,values:u,plugins:[j(void 0,a),Z()],dropZoneClass:"opacity-0",touchDropZoneClass:"opacity-0"}),(r,l)=>{const C=O("CommonIcon"),_=O("CommonLabel"),w=O("CommonBadge");return i.value?(c(),b("div",Y,[p("span",ee,v(r.$t("Drag and drop to reorder ticket overview list items.")),1),p("ul",re,[(c(!0),b(E,null,Q(u.value,e=>(c(),b("li",{key:e.id,class:"draggable flex min-h-9 cursor-grab items-start gap-2.5 p-2.5 active:cursor-grabbing",draggable:"true","aria-describedby":"drag-and-drop-ticket-overviews"},[m(C,{class:"mt-1 shrink-0 fill-stone-200 dark:fill-neutral-500",name:"grip-vertical",size:"tiny",decorative:""}),p("div",te,[m(_,{class:"inline text-black dark:text-white"},{default:n(()=>[f(v(r.$t(e.name)),1)]),_:2},1024),e.organizationShared?(c(),h(w,{key:0,variant:"info",class:"ms-1.5"},{default:n(()=>[f(v(r.$t("Only when shared organization member")),1)]),_:1})):y("",!0),e.outOfOffice?(c(),h(w,{key:1,variant:"info",class:"ms-1.5"},{default:n(()=>[f(v(r.$t("Only when out of office replacement")),1)]),_:1})):y("",!0)])]))),128))],512)])):y("",!0)}}}),se=g`
    mutation userCurrentOverviewResetOrder {
  userCurrentOverviewResetOrder {
    success
    overviews {
      id
      name
    }
    errors {
      ...errors
    }
  }
}
    ${B}`;function ie(s={}){return N(se,s)}const ne=g`
    mutation userCurrentOverviewUpdateOrder($overviewIds: [ID!]!) {
  userCurrentOverviewUpdateOrder(overviewIds: $overviewIds) {
    success
    errors {
      ...errors
    }
  }
}
    ${B}`;function ae(s={}){return N(ne,s)}const de=g`
    query userCurrentOverviewList($ignoreUserConditions: Boolean!) {
  userCurrentTicketOverviews(ignoreUserConditions: $ignoreUserConditions) {
    id
    name
    organizationShared
    outOfOffice
  }
}
    `;function ue(s,i={}){return z(de,s,i)}const ce={class:"mb-4"},ve={class:"flex flex-col items-end"},Ae=L({__name:"PersonalSettingOverviews",setup(s){const{breadcrumbItems:i}=K(__("Overviews")),a=D([]),d=new V(ue({ignoreUserConditions:!0})),u=d.loading();S(()=>d.refetch()),d.subscribeToMore({document:W,variables:{ignoreUserConditions:!0},updateQuery:(e,{subscriptionData:t})=>{var o;return(o=t.data)!=null&&o.userCurrentOverviewOrderingUpdates.overviews?{userCurrentTicketOverviews:t.data.userCurrentOverviewOrderingUpdates.overviews}:null}}),R(d.result(),e=>{a.value=(e==null?void 0:e.userCurrentTicketOverviews)||[]});const{notify:r}=q(),l=e=>{a.value=e,new U(ae(),{errorNotificationMessage:__("Updating the order of your ticket overviews failed.")}).send({overviewIds:e.map(o=>o.id)}).then(()=>{r({id:"overview-ordering-success",type:$.Success,message:__("The order of your ticket overviews was updated.")})})},{waitForVariantConfirmation:C}=P(),_=()=>{new U(ie(),{errorNotificationMessage:__("Resetting the order of your ticket overviews failed.")}).send().then(t=>{var o;(o=t==null?void 0:t.userCurrentOverviewResetOrder)!=null&&o.success&&(r({id:"overview-ordering-delete-success",type:$.Success,message:__("The order of your ticket overviews was reset.")}),t.userCurrentOverviewResetOrder.overviews&&(a.value=t.userCurrentOverviewResetOrder.overviews))})},w=async()=>{await C("confirm")&&_()};return(e,t)=>{const o=O("CommonLabel");return c(),h(H,{"breadcrumb-items":k(i),width:"narrow"},{default:n(()=>[m(F,{class:"mt-5 mb-3",loading:k(u)},{default:n(()=>[p("div",ce,[m(o,{id:"label-ticket-overview-order",class:"!mt-0.5 mb-1 !block"},{default:n(()=>[f(v(e.$t("Order of ticket overviews")),1)]),_:1}),m(oe,{"model-value":a.value,"aria-labelledby":"label-ticket-overview-order","onUpdate:modelValue":l},null,8,["model-value"]),p("div",ve,[m(A,{"aria-label":e.$t("Reset Overview Order"),class:"mt-4",variant:"danger",size:"medium",onClick:x(w,["stop"])},{default:n(()=>[f(v(e.$t("Reset Overview Order")),1)]),_:1},8,["aria-label"])])])]),_:1},8,["loading"])]),_:1},8,["breadcrumb-items"])}}});export{Ae as default};
//# sourceMappingURL=PersonalSettingOverviews-DFzswbk0.js.map
