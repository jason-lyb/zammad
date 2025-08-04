import{e as p,u as F}from"./routes-CgLO9M4y.js";import{d as m,r as g,c as n}from"./vue-oicRkvo0.js";import{n as A}from"./vendor-C11O1Xx8.js";import{X as T}from"./overviewAttributes.api-C09LSZ8O.js";import{e as y}from"./apollo-Cj5TVUDk.js";const{twoFactorMethodLookup:$,twoFactorMethods:b}=F(),D=a=>{const l=p(),t=m({state:"credentials",allowedMethods:[],defaultMethod:void 0,recoveryCodesAvailable:!1}),u=g([t.state]),i=(e,o=!1)=>{o||a(),u.value.push(e),t.state=e},r=(e,o=!1)=>{o||a(),t.twoFactor=e,i("2fa",!0)},h=(e,o)=>{a(),t.credentials=o,t.recoveryCodesAvailable=e.recoveryCodesAvailable,t.allowedMethods=e.availableTwoFactorAuthenticationMethods,t.defaultMethod=e.defaultTwoFactorAuthenticationMethod,r(e.defaultTwoFactorAuthenticationMethod,!0)},s=n(()=>b.filter(e=>t.allowedMethods.includes(e.name))),c=n(()=>t.twoFactor?$[t.twoFactor]:void 0),f=n(()=>s.value.length>1||t.recoveryCodesAvailable),d={credentials:null,"2fa":"credentials","2fa-select":"2fa","recovery-code":"2fa-select"},w=()=>{a();const e=d[t.state]||"credentials";t.state=e,e==="credentials"&&(t.credentials=void 0)},M=()=>{a(),t.state="credentials",t.credentials=void 0},v=n(()=>{var o;const e=l.config.product_name;return t.state==="credentials"?e:t.state==="recovery-code"?__("Recovery Code"):t.state==="2fa"?((o=c.value)==null?void 0:o.label)??e:__("Try Another Method")});return{loginFlow:t,hasAlternativeLoginMethod:f,askTwoFactor:h,twoFactorPlugin:c,twoFactorAllowedMethods:s,updateState:i,updateSecondFactor:r,goBack:w,cancelAndGoBack:M,statePreviousMap:d,loginPageTitle:v}},S=A`
    mutation twoFactorMethodInitiateAuthentication($login: String!, $password: String!, $twoFactorMethod: EnumTwoFactorAuthenticationMethod!) {
  twoFactorMethodInitiateAuthentication(
    login: $login
    password: $password
    twoFactorMethod: $twoFactorMethod
  ) {
    initiationData
    errors {
      ...errors
    }
  }
}
    ${T}`;function L(a={}){return y(S,a)}export{D as a,L as u};
//# sourceMappingURL=twoFactorMethodInitiateAuthentication.api-DmImhgjQ.js.map
