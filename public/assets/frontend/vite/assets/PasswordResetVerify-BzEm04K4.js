import{f as N,r as u,ap as U,ao as x,m,D as p,y as r,q as d,Q as _,M as g,u as l,E as y}from"./vue-oicRkvo0.js";import{e as b,M as k,N as D,c as T}from"./apollo-Cj5TVUDk.js";import{_ as q}from"./Form.vue_vue_type_script_setup_true_lang-B6L-6HzY.js";import{u as B}from"./useForm-CUKec4n5.js";import{e as E,T as L}from"./routes-CgLO9M4y.js";import{c as v,d as z}from"./desktop-l0eJ1dZN.js";import{_ as F}from"./CommonPublicLinks.vue_vue_type_script_setup_true_lang-DcbvsgxJ.js";import{_ as A}from"./LayoutPublicPage.vue_vue_type_script_setup_true_lang-C_6Ob6yy.js";import{n as P}from"./vendor-C11O1Xx8.js";import{X as $}from"./overviewAttributes.api-C09LSZ8O.js";import"./lodash-pFOI14f-.js";import"./formkit-5nol1GBe.js";import"./FormGroup.vue_vue_type_script_setup_true_lang-DIx-HUKU.js";import"./vite-FJshFMF2.js";import"./useCopyToClipboard-CjkPg__g.js";import"./theme-Bv2ClBzZ.js";import"./datepicker-BBNcWeHz.js";import"./date-B2UyDZN7.js";import"./autocompleteTags.api-CG5-cm_A.js";import"./autocompleteSearchTicket.api-DfOQWGlO.js";import"./ticketUpdates.api-BhGIG_Ti.js";import"./ticketAttributes.api-rqx5ITab.js";import"./useTicketCreateArticleType-D7iVcJ_6.js";import"./types-Cu-Nkl7K.js";import"./useTicketCreateView-HCH46SPv.js";import"./commonjsHelpers-BosuxZz1.js";import"./usePublicLinks-CDMBq4UM.js";import"./CommonLogo.vue_vue_type_script_setup_true_lang-xQq9wMEL.js";import"./useLogoUrl-8sIhej5J.js";import"./LayoutPublicPageBoxActions-BFjF_v1c.js";const H=P`
    mutation userPasswordResetUpdate($token: String!, $password: String!) {
  userPasswordResetUpdate(token: $token, password: $password) {
    success
    errors {
      ...errors
    }
  }
}
    ${$}`;function G(e={}){return b(H,e)}const Q=P`
    mutation userPasswordResetVerify($token: String!) {
  userPasswordResetVerify(token: $token) {
    success
    errors {
      ...errors
    }
  }
}
    ${$}`;function W(e={}){return b(Q,e)}const Pe=N({beforeRouteEnter(e){return E().config.user_lost_password?!0:e.redirectedFrom?!1:"/"},__name:"PasswordResetVerify",props:{token:{}},setup(e){const t=e,S=[{type:"password",label:__("Password"),name:"password",outerClass:"col-span-1",required:!0,props:{maxLength:1001}},{type:"password",label:__("Confirm password"),name:"password_confirm",outerClass:"col-span-1",validation:"confirm",props:{maxLength:1001},required:!0}],{form:h,isDisabled:c}=B(),a=u(""),n=u(!0),o=u(!1),{notify:R}=T(),f=U();x(()=>{if(!t.token){n.value=!1,o.value=!1,a.value=__("The token could not be verified. Please contact your administrator.");return}new k(W({variables:{token:t.token}}),{errorShowNotification:!1}).send().then(()=>{o.value=!0,a.value=""}).catch(()=>{o.value=!1,a.value=__("The provided token is invalid.")}).finally(()=>{n.value=!1})});const C=new k(G(),{errorShowNotification:!1}),V=async s=>{await C.send({token:t.token,password:s.password}),R({id:"password-change",type:D.Success,message:__("Woo hoo! Your password has been changed!")}),f.replace("/login")},M=()=>{f.replace("/login")};return(s,i)=>(m(),p(A,{"box-size":"medium",title:s.__("Choose your new password")},{boxActions:r(()=>[d(v,{variant:"secondary",size:"medium",disabled:l(c),onClick:i[1]||(i[1]=w=>M())},{default:r(()=>[_(g(s.$t("Cancel & Go Back")),1)]),_:1},8,["disabled"]),o.value?(m(),p(v,{key:0,type:"submit",variant:"submit",size:"medium",form:"password-reset-verify",disabled:l(c)},{default:r(()=>[_(g(s.$t("Submit")),1)]),_:1},8,["disabled"])):y("",!0)]),bottomContent:r(()=>[d(F,{screen:l(L).PasswordReset},null,8,["screen"])]),default:r(()=>[d(z,{loading:n.value,error:a.value},null,8,["loading","error"]),o.value?(m(),p(q,{key:0,id:"password-reset-verify",ref_key:"form",ref:h,"form-class":"mb-2.5 grid grid-cols-2 gap-y-2.5 gap-x-3",schema:S,onSubmit:i[0]||(i[0]=w=>V(w))},null,512)):y("",!0)]),_:1},8,["title"]))}});export{Pe as default};
//# sourceMappingURL=PasswordResetVerify-BzEm04K4.js.map
