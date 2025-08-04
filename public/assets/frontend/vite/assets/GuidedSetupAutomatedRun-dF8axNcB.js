import{f as S,ap as y,r as f,c as h,a1 as k,m as n,D as i,y as l,Q as v,M as z}from"./vue-oicRkvo0.js";import{S as R,F as M}from"./routes-CgLO9M4y.js";import{e as W,M as w}from"./apollo-Cj5TVUDk.js";import{X as x,a4 as $}from"./overviewAttributes.api-C09LSZ8O.js";import{_ as C}from"./LayoutPublicPage.vue_vue_type_script_setup_true_lang-C_6Ob6yy.js";import{h as D}from"./desktop-l0eJ1dZN.js";import{_ as F}from"./GuidedSetupStatusMessage.vue_vue_type_script_setup_true_lang-CK-LgkYz.js";import{n as b}from"./vendor-C11O1Xx8.js";import"./vite-FJshFMF2.js";import"./lodash-pFOI14f-.js";import"./formkit-5nol1GBe.js";import"./CommonLogo.vue_vue_type_script_setup_true_lang-xQq9wMEL.js";import"./useLogoUrl-8sIhej5J.js";import"./LayoutPublicPageBoxActions-BFjF_v1c.js";import"./Form.vue_vue_type_script_setup_true_lang-B6L-6HzY.js";import"./FormGroup.vue_vue_type_script_setup_true_lang-DIx-HUKU.js";import"./useForm-CUKec4n5.js";import"./useCopyToClipboard-CjkPg__g.js";import"./theme-Bv2ClBzZ.js";import"./datepicker-BBNcWeHz.js";import"./date-B2UyDZN7.js";import"./autocompleteTags.api-CG5-cm_A.js";import"./autocompleteSearchTicket.api-DfOQWGlO.js";import"./ticketUpdates.api-BhGIG_Ti.js";import"./ticketAttributes.api-rqx5ITab.js";import"./useTicketCreateArticleType-D7iVcJ_6.js";import"./types-Cu-Nkl7K.js";import"./useTicketCreateView-HCH46SPv.js";import"./commonjsHelpers-BosuxZz1.js";const B=b`
    mutation systemSetupRunAutoWizard($token: String) {
  systemSetupRunAutoWizard(token: $token) {
    session {
      ...session
    }
    errors {
      ...errors
    }
  }
}
    ${R}
${x}`;function T(r={}){return W(B,r)}const dt=S({__name:"GuidedSetupAutomatedRun",props:{token:{}},setup(r){const _=r,{fingerprint:A}=M(),a=y(),u=f(!1),s=f();new w(T({variables:{token:_.token},context:{headers:{"X-Browser-Fingerprint":A.value}}})).send().then(async t=>{var o,e,p,c;u.value=!0;const{setAuthenticatedSessionId:m}=$();if(await m(((e=(o=t==null?void 0:t.systemSetupRunAutoWizard)==null?void 0:o.session)==null?void 0:e.id)||null)){const d=(c=(p=t==null?void 0:t.systemSetupRunAutoWizard)==null?void 0:p.session)==null?void 0:c.afterAuth;window.setTimeout(()=>{if(d){D(a,d);return}a.replace("/")},2e3)}}).catch(t=>{s.value=t});const g=h(()=>u.value?__("The system was configured successfully. You are being redirected."):__("Relax, your system is being set up…"));return(t,m)=>{const o=k("CommonAlert");return n(),i(C,{"box-size":"medium",title:t.__("Automated Setup")},{default:l(()=>[s.value?(n(),i(o,{key:1,variant:"danger"},{default:l(()=>{var e;return[v(z((e=s.value)==null?void 0:e.generalErrors[0]),1)]}),_:1})):(n(),i(F,{key:0,message:g.value},null,8,["message"]))]),_:1},8,["title"])}}});export{dt as default};
//# sourceMappingURL=GuidedSetupAutomatedRun-dF8axNcB.js.map
