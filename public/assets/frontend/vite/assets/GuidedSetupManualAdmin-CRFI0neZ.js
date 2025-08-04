import{f as A,ap as _,s as F,m as b,p as y,q as p,u as d,J as k}from"./vue-oicRkvo0.js";import{_ as $}from"./Form.vue_vue_type_script_setup_true_lang-B6L-6HzY.js";import{S as h,F as w}from"./routes-CgLO9M4y.js";import{e as B,M}from"./apollo-Cj5TVUDk.js";import{X as x,a4 as C}from"./overviewAttributes.api-C09LSZ8O.js";import{u as E}from"./useSignupForm-BkEm3_Qx.js";import{_ as R}from"./GuidedSetupActionFooter.vue_vue_type_script_setup_true_lang-Cze7-cY3.js";import{u as U}from"./useSystemSetup-CBS5N4Hd.js";import{n as v}from"./vendor-C11O1Xx8.js";import{s as D}from"./systemSetupBeforeRouteEnterGuard-BnxOQYpQ.js";import{u as G}from"./systemSetupInfo-CpheL1LK.js";import"./formkit-5nol1GBe.js";import"./FormGroup.vue_vue_type_script_setup_true_lang-DIx-HUKU.js";import"./lodash-pFOI14f-.js";import"./vite-FJshFMF2.js";import"./useForm-CUKec4n5.js";import"./desktop-l0eJ1dZN.js";import"./useCopyToClipboard-CjkPg__g.js";import"./theme-Bv2ClBzZ.js";import"./datepicker-BBNcWeHz.js";import"./date-B2UyDZN7.js";import"./autocompleteTags.api-CG5-cm_A.js";import"./autocompleteSearchTicket.api-DfOQWGlO.js";import"./ticketUpdates.api-BhGIG_Ti.js";import"./ticketAttributes.api-rqx5ITab.js";import"./useTicketCreateArticleType-D7iVcJ_6.js";import"./types-Cu-Nkl7K.js";import"./useTicketCreateView-HCH46SPv.js";import"./commonjsHelpers-BosuxZz1.js";import"./LayoutPublicPageBoxActions-BFjF_v1c.js";const I=v`
    mutation userAddFirstAdmin($input: UserSignupInput!) {
  userAddFirstAdmin(input: $input) {
    session {
      ...session
    }
    errors {
      ...errors
    }
  }
}
    ${h}
${x}`;function q(o={}){return B(I,o)}const lt=A({beforeRouteEnter:D,__name:"GuidedSetupManualAdmin",setup(o){const{setTitle:c}=U();c(__("Create Administrator Account"));const n=_(),i=F(),{signupSchema:f}=E(),{systemSetupUnlock:m}=G(),l=async t=>{const{fingerprint:r}=w();return new M(q({context:{headers:{"X-Browser-Fingerprint":r.value}}})).send({input:{firstname:t.firstname,lastname:t.lastname,email:t.email,password:t.password}}).then(async e=>{var u,a;const{setAuthenticatedSessionId:g}=C();await g(((a=(u=e==null?void 0:e.userAddFirstAdmin)==null?void 0:u.session)==null?void 0:a.id)||null)&&m(()=>{n.push("/guided-setup/manual/system-information")})})},S=()=>{n.replace("/guided-setup")};return(t,r)=>(b(),y(k,null,[p($,{id:"admin-signup",ref_key:"form",ref:i,"form-class":"mb-2.5",schema:d(f),onSubmit:r[0]||(r[0]=s=>l(s))},null,8,["schema"]),p(R,{form:i.value,"submit-button-text":t.__("Create account"),onGoBack:r[1]||(r[1]=s=>d(m)(S))},null,8,["form","submit-button-text"])],64))}});export{lt as default};
//# sourceMappingURL=GuidedSetupManualAdmin-CRFI0neZ.js.map
