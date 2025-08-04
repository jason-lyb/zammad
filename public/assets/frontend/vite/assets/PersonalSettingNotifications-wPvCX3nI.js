import{n as $,u as O}from"./vendor-C11O1Xx8.js";import{e as h,M as p,N as _,c as q}from"./apollo-Cj5TVUDk.js";import{_ as A}from"./Form.vue_vue_type_script_setup_true_lang-B6L-6HzY.js";import{u as L}from"./useForm-CUKec4n5.js";import{X as x,Y as j,Z as z,a2 as G}from"./overviewAttributes.api-C09LSZ8O.js";import{aa as P,a as Q,ab as b,r as X}from"./routes-CgLO9M4y.js";import{c as g}from"./desktop-l0eJ1dZN.js";import{a as Y}from"./LayoutContent.vue_vue_type_script_setup_true_lang-SafgfcNL.js";import{u as H}from"./useBreadcrumb-DUhE6wbZ.js";import{b as v}from"./lodash-pFOI14f-.js";import{f as V,r as Z,c as J,w as K,m as W,D as ee,y as n,I as y,q as u,Q as N,M as U,u as c}from"./vue-oicRkvo0.js";import"./commonjsHelpers-BosuxZz1.js";import"./formkit-5nol1GBe.js";import"./FormGroup.vue_vue_type_script_setup_true_lang-DIx-HUKU.js";import"./vite-FJshFMF2.js";import"./useCopyToClipboard-CjkPg__g.js";import"./theme-Bv2ClBzZ.js";import"./datepicker-BBNcWeHz.js";import"./date-B2UyDZN7.js";import"./autocompleteTags.api-CG5-cm_A.js";import"./autocompleteSearchTicket.api-DfOQWGlO.js";import"./ticketUpdates.api-BhGIG_Ti.js";import"./ticketAttributes.api-rqx5ITab.js";import"./useTicketCreateArticleType-D7iVcJ_6.js";import"./types-Cu-Nkl7K.js";import"./useTicketCreateView-HCH46SPv.js";import"./LayoutMain.vue_vue_type_script_setup_true_lang-DIWzj6-0.js";import"./LayoutSidebar.vue_vue_type_script_setup_true_lang-BO1pkKrb.js";import"./useResizeGridColumns-CieKHty_.js";const te=$`
    mutation userCurrentNotificationPreferencesReset {
  userCurrentNotificationPreferencesReset {
    user {
      ...userPersonalSettings
    }
    errors {
      ...errors
    }
  }
}
    ${P}
${x}`;function ie(o={}){return h(te,o)}const re=$`
    mutation userCurrentNotificationPreferencesUpdate($groupIds: [ID!], $matrix: UserNotificationMatrixInput!, $sound: UserNotificationSoundInput!) {
  userCurrentNotificationPreferencesUpdate(
    groupIds: $groupIds
    matrix: $matrix
    sound: $sound
  ) {
    user {
      ...userPersonalSettings
    }
    errors {
      ...errors
    }
  }
}
    ${P}
${x}`;function se(o={}){return h(re,o)}const ae={class:"mb-4"},oe={class:"flex justify-end gap-2"},Be=V({__name:"PersonalSettingNotifications",setup(o){const{breadcrumbItems:S}=H(__("Notifications")),{user:C}=O(Q()),{notify:f}=q(),{waitForConfirmation:F}=G(),s=Z(!1),{form:m,onChangedField:M,formReset:I,values:D,isDirty:R}=L(),w=Object.keys(b).map(e=>({label:e,value:e})),T=j([{type:"notifications",name:"matrix",label:__("Notification matrix"),labelSrOnly:!0},{type:"select",name:"group_ids",label:__("Limit notifications to specific groups"),help:__("Affects only notifications for not assigned and all tickets."),props:{clearable:!0,multiple:!0,noOptionsLabelTranslation:!0}},{type:"select",name:"file",label:__("Notification sound"),props:{options:w}},{type:"toggle",name:"enabled",label:__("Play user interface sound effects"),props:{variants:{true:"True",false:"False"}}}]),l=J(e=>{var a;const{notificationConfig:i={},notificationSound:t={}}=((a=C.value)==null?void 0:a.personalSettings)||{},r={group_ids:(i==null?void 0:i.groupIds)??[],matrix:(i==null?void 0:i.matrix)||{},file:(t==null?void 0:t.file)??b.Xylo,enabled:(t==null?void 0:t.enabled)??!0};return e&&v(r,e)?e:r});K(l,e=>{v(D.value,e)&&!R.value||I({values:e})}),M("file",e=>{var i;(i=new Audio(`/assets/sounds/${e==null?void 0:e.toString()}.mp3`))==null||i.play()});const k=async e=>{var t;return s.value=!0,new p(se(),{errorNotificationMessage:__("Notification settings could not be saved.")}).send({matrix:e.matrix,groupIds:((t=e==null?void 0:e.group_ids)==null?void 0:t.map(r=>z("Group",r)))||[],sound:{file:e.file,enabled:e.enabled}}).then(r=>{r!=null&&r.userCurrentNotificationPreferencesUpdate&&f({id:"notification-update-success",type:_.Success,message:__("Notification settings have been saved successfully.")})}).finally(()=>{s.value=!1})},B=e=>{var i,t;(t=m.value)==null||t.resetForm({values:{matrix:((i=e==null?void 0:e.notificationConfig)==null?void 0:i.matrix)||{}}})},E=async()=>await F(__("Are you sure? Your notifications settings will be reset to default."))?(s.value=!0,new p(ie(),{errorNotificationMessage:__("Notification settings could not be reset.")}).send().then(t=>{var a,d;const r=(d=(a=t==null?void 0:t.userCurrentNotificationPreferencesReset)==null?void 0:a.user)==null?void 0:d.personalSettings;r&&(B(r),f({id:"notification-reset-success",type:_.Success,message:__("Notification settings have been reset to default.")}))}).finally(()=>{s.value=!1})):void 0;return(e,i)=>(W(),ee(Y,{"breadcrumb-items":c(S),width:"narrow"},{default:n(()=>[y("div",ae,[u(A,{id:"notifications-form",ref_key:"form",ref:m,schema:c(T),"form-updater-id":c(X).FormUpdaterUpdaterUserNotifications,"form-updater-initial-only":"","initial-values":l.value,onSubmit:i[0]||(i[0]=t=>k(t))},{"after-fields":n(()=>[y("div",oe,[u(g,{size:"medium",variant:"danger",disabled:s.value,onClick:E},{default:n(()=>[N(U(e.$t("Reset to Default Settings")),1)]),_:1},8,["disabled"]),u(g,{size:"medium",type:"submit",variant:"submit",disabled:s.value},{default:n(()=>[N(U(e.$t("Save Notifications")),1)]),_:1},8,["disabled"])])]),_:1},8,["schema","form-updater-id","initial-values"])])]),_:1},8,["breadcrumb-items"]))}});export{Be as default};
//# sourceMappingURL=PersonalSettingNotifications-wPvCX3nI.js.map
