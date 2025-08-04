import{n as b,u as oe}from"./vendor-C11O1Xx8.js";import{e as ae,u as ie,Q as re,M as le,N as ue,c as pe}from"./apollo-Cj5TVUDk.js";import{_ as ce}from"./Form.vue_vue_type_script_setup_true_lang-B6L-6HzY.js";import{u as de}from"./useForm-CUKec4n5.js";import{u as me}from"./useMultiStepForm-CbTGEQR9.js";import{X as be,Y as ge}from"./overviewAttributes.api-C09LSZ8O.js";import{a as fe}from"./routes-CgLO9M4y.js";import{_ as R}from"./CommonInputCopyToClipboard.vue_vue_type_script_setup_true_lang-CO4uQ3Xg.js";import{l as _e}from"./desktop-l0eJ1dZN.js";import{a as ye}from"./LayoutContent.vue_vue_type_script_setup_true_lang-SafgfcNL.js";import{u as Ce}from"./useBreadcrumb-DUhE6wbZ.js";import{b as D}from"./lodash-pFOI14f-.js";import{f as Se,d as ve,w as m,c,r as we,a1 as F,m as he,D as ke,y as V,I as Q,q as i,u as s,Q as Le,M as Oe,b as Ue}from"./vue-oicRkvo0.js";import"./commonjsHelpers-BosuxZz1.js";import"./formkit-5nol1GBe.js";import"./FormGroup.vue_vue_type_script_setup_true_lang-DIx-HUKU.js";import"./vite-FJshFMF2.js";import"./useCopyToClipboard-CjkPg__g.js";import"./theme-Bv2ClBzZ.js";import"./datepicker-BBNcWeHz.js";import"./date-B2UyDZN7.js";import"./autocompleteTags.api-CG5-cm_A.js";import"./autocompleteSearchTicket.api-DfOQWGlO.js";import"./ticketUpdates.api-BhGIG_Ti.js";import"./ticketAttributes.api-rqx5ITab.js";import"./useTicketCreateArticleType-D7iVcJ_6.js";import"./types-Cu-Nkl7K.js";import"./useTicketCreateView-HCH46SPv.js";import"./LayoutMain.vue_vue_type_script_setup_true_lang-DIWzj6-0.js";import"./LayoutSidebar.vue_vue_type_script_setup_true_lang-BO1pkKrb.js";import"./useResizeGridColumns-CieKHty_.js";const Ae=b`
    mutation userCurrentCalendarSubscriptionUpdate($input: UserCalendarSubscriptionsConfigInput!) {
  userCurrentCalendarSubscriptionUpdate(input: $input) {
    success
    errors {
      ...errors
    }
  }
}
    ${be}`;function Ne(l={}){return ae(Ae,l)}const $e=b`
    fragment userCalendarSubscriptionAttributes on UserPersonalSettingsCalendarSubscriptionsConfig {
  combinedUrl
  globalOptions {
    alarm
  }
  newOpen {
    url
    options {
      own
      notAssigned
    }
  }
  pending {
    url
    options {
      own
      notAssigned
    }
  }
  escalation {
    url
    options {
      own
      notAssigned
    }
  }
}
    `,Me=b`
    query userCurrentCalendarSubscriptionList {
  userCurrentCalendarSubscriptionList {
    ...userCalendarSubscriptionAttributes
  }
}
    ${$e}`;function Be(l={}){return ie(Me,{},l)}const Ie={class:"mb-4"},Re=["id","aria-labelledby"],mn=Se({__name:"PersonalSettingCalendar",setup(l){const{breadcrumbItems:T}=Ce(__("Calendar")),{form:q,isDirty:P,node:E,formReset:x,formSubmit:g,values:G}=de(),{multiStepPlugin:H,allSteps:K,activeStep:o}=me(E),d=(e,n)=>({isLayout:!0,element:"section",attrs:{style:{if:`$activeStep !== "${e}"`,then:"display: none;"}},children:[{type:"group",name:e,isGroupOrList:!0,plugins:[H],children:n}]}),Y=d("escalation",[{name:"escalationOwn",type:"toggle",label:__("My tickets"),help:__("Include your own tickets in subscription for escalated tickets."),props:{variants:{true:"yes",false:"no"}}},{name:"escalationNotAssigned",type:"toggle",label:__("Not assigned"),help:__("Include unassigned tickets in subscription for escalated tickets."),props:{variants:{true:"yes",false:"no"}}}]),j=d("newOpen",[{name:"newOpenOwn",type:"toggle",label:__("My tickets"),help:__("Include your own tickets in subscription for new & open tickets."),props:{variants:{true:"yes",false:"no"}}},{name:"newOpenNotAssigned",type:"toggle",label:__("Not assigned"),help:__("Include unassigned tickets in subscription for new & open tickets."),props:{variants:{true:"yes",false:"no"}}}]),z=d("pending",[{name:"pendingOwn",type:"toggle",label:__("My tickets"),help:__("Include your own tickets in subscription for pending tickets."),props:{variants:{true:"yes",false:"no"}}},{name:"pendingNotAssigned",type:"toggle",label:__("Not assigned"),help:__("Include unassigned tickets in subscription for pending tickets."),props:{variants:{true:"yes",false:"no"}}}]),X=ge([Y,j,z]),J=ve({activeStep:o}),f=new re(Be()),t=f.result(),{user:W}=oe(fe());m(()=>{var e,n;return(n=(e=W.value)==null?void 0:e.preferences)==null?void 0:n.calendar_subscriptions},()=>{f.refetch()},{deep:!0});const Z=c(()=>{var e;return((e=t.value)==null?void 0:e.userCurrentCalendarSubscriptionList.combinedUrl)??""}),_=c(()=>{var e,n;return!!((n=(e=t.value)==null?void 0:e.userCurrentCalendarSubscriptionList.globalOptions)!=null&&n.alarm)}),u=we(_.value);m(_,e=>{u.value=e});const ee=c(()=>{var e,n;return((n=(e=t.value)==null?void 0:e.userCurrentCalendarSubscriptionList[o.value])==null?void 0:n.url)??""}),y=c(e=>{var r,p,a,C,S,v,w,h,k,L,O,U,A,N,$,M,B,I;const n={escalationOwn:(a=(p=(r=t.value)==null?void 0:r.userCurrentCalendarSubscriptionList.escalation)==null?void 0:p.options)==null?void 0:a.own,escalationNotAssigned:(v=(S=(C=t.value)==null?void 0:C.userCurrentCalendarSubscriptionList.escalation)==null?void 0:S.options)==null?void 0:v.notAssigned,newOpenOwn:(k=(h=(w=t.value)==null?void 0:w.userCurrentCalendarSubscriptionList.newOpen)==null?void 0:h.options)==null?void 0:k.own,newOpenNotAssigned:(U=(O=(L=t.value)==null?void 0:L.userCurrentCalendarSubscriptionList.newOpen)==null?void 0:O.options)==null?void 0:U.notAssigned,pendingOwn:($=(N=(A=t.value)==null?void 0:A.userCurrentCalendarSubscriptionList.pending)==null?void 0:N.options)==null?void 0:$.own,pendingNotAssigned:(I=(B=(M=t.value)==null?void 0:M.userCurrentCalendarSubscriptionList.pending)==null?void 0:B.options)==null?void 0:I.notAssigned};return e&&D(n,e)?e:n});m(y,e=>{D(G.value,e)&&!P.value||x({values:e})});const{notify:ne}=pe(),te=async e=>{const n={alarm:u.value,escalation:{own:!!e.escalationOwn,notAssigned:!!e.escalationNotAssigned},newOpen:{own:!!e.newOpenOwn,notAssigned:!!e.newOpenNotAssigned},pending:{own:!!e.pendingOwn,notAssigned:!!e.pendingNotAssigned}};return new le(Ne(),{errorNotificationMessage:__("Updating your calendar subscription settings failed.")}).send({input:n}).then(()=>{ne({id:"calendar-subscription-update-success",type:ue.Success,message:__("You calendar subscription settings were updated.")})})},se=[{label:__("Escalated Tickets"),key:"escalation"},{label:__("New & Open Tickets"),key:"newOpen"},{label:__("Pending Tickets"),key:"pending"}];return(e,n)=>{const r=F("FormKit"),p=F("CommonLabel");return he(),ke(ye,{"breadcrumb-items":s(T),"help-text":e.$t("See your tickets from within your favorite calendar by adding the subscription URL to your calendar app."),width:"narrow"},{default:V(()=>[Q("div",Ie,[i(R,{label:e.__("Combined subscription URL"),"copy-button-text":e.__("Copy URL"),value:Z.value,help:e.__("Includes escalated, new & open and pending tickets.")},null,8,["label","copy-button-text","value","help"]),i(r,{modelValue:u.value,"onUpdate:modelValue":[n[0]||(n[0]=a=>u.value=a),s(g)],type:"toggle",label:e.__("Add alarm to pending reminder and escalated tickets"),variants:{true:"yes",false:"no"}},null,8,["modelValue","label","onUpdate:modelValue"]),i(p,{role:"heading","aria-level":"2",class:"mt-5 mb-2",size:"large"},{default:V(()=>[Le(Oe(e.$t("Subscription settings")),1)]),_:1}),i(_e,{modelValue:s(o),"onUpdate:modelValue":n[1]||(n[1]=a=>Ue(o)?o.value=a:null),class:"mb-3",tabs:se},null,8,["modelValue"]),Q("div",{id:`tab-panel-${s(o)}`,role:"tabpanel","aria-labelledby":`tab-label-${s(o)}`},[i(R,{label:e.__("Direct subscription URL"),"copy-button-text":e.__("Copy URL"),value:ee.value},null,8,["label","copy-button-text","value"]),i(ce,{id:"calendar-subscription",ref_key:"form",ref:q,schema:s(X),"flatten-form-groups":Object.keys(s(K)),"initial-values":y.value,"schema-data":J,onChanged:s(g),onSubmit:te},null,8,["schema","flatten-form-groups","initial-values","schema-data","onChanged"])],8,Re)])]),_:1},8,["breadcrumb-items","help-text"])}}});export{mn as default};
//# sourceMappingURL=PersonalSettingCalendar-DzSLMgJb.js.map
