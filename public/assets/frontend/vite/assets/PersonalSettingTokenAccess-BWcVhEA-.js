const __vite__mapDeps=(i,m=__vite__mapDeps,d=(m.f||(m.f=["assets/PersonalSettingNewAccessTokenFlyout-DP1QVHe4.js","assets/Form.vue_vue_type_script_setup_true_lang-B6L-6HzY.js","assets/vue-oicRkvo0.js","assets/vendor-C11O1Xx8.js","assets/commonjsHelpers-BosuxZz1.js","assets/formkit-5nol1GBe.js","assets/apollo-Cj5TVUDk.js","assets/lodash-pFOI14f-.js","assets/overviewAttributes.api-C09LSZ8O.js","assets/routes-CgLO9M4y.js","assets/vite-FJshFMF2.js","assets/overviewAttributes-r_4zXopK.css","assets/FormGroup.vue_vue_type_script_setup_true_lang-DIx-HUKU.js","assets/Form-BSACsGR2.css","assets/useForm-CUKec4n5.js","assets/CommonFlyout.vue_vue_type_script_setup_true_lang-Cr1ukr3s.js","assets/desktop-l0eJ1dZN.js","assets/useCopyToClipboard-CjkPg__g.js","assets/theme-Bv2ClBzZ.js","assets/datepicker-BBNcWeHz.js","assets/date-B2UyDZN7.js","assets/autocompleteTags.api-CG5-cm_A.js","assets/autocompleteSearchTicket.api-DfOQWGlO.js","assets/ticketUpdates.api-BhGIG_Ti.js","assets/ticketAttributes.api-rqx5ITab.js","assets/useTicketCreateArticleType-D7iVcJ_6.js","assets/types-Cu-Nkl7K.js","assets/useTicketCreateView-HCH46SPv.js","assets/desktop-BAkSnNV9.css","assets/CommonOverlayContainer.vue_vue_type_script_setup_true_lang-CxyKmNUC.js","assets/LayoutSidebar.vue_vue_type_script_setup_true_lang-BO1pkKrb.js","assets/useFlyout-KZXqW5RR.js","assets/CommonInputCopyToClipboard.vue_vue_type_script_setup_true_lang-CO4uQ3Xg.js","assets/LayoutContent.vue_vue_type_script_setup_true_lang-SafgfcNL.js","assets/LayoutMain.vue_vue_type_script_setup_true_lang-DIWzj6-0.js","assets/useResizeGridColumns-CieKHty_.js","assets/useBreadcrumb-DUhE6wbZ.js"])))=>i.map(i=>d[i]);
import{_ as x}from"./vite-FJshFMF2.js";import{e as E,u as I,E as M,Q as N,M as Q,N as F,c as S}from"./apollo-Cj5TVUDk.js";import{X as B,aT as R,aU as V,a2 as q}from"./overviewAttributes.api-C09LSZ8O.js";import{n as c}from"./vendor-C11O1Xx8.js";import{ad as j,i as p}from"./routes-CgLO9M4y.js";import{c as z,k as H,d as O}from"./desktop-l0eJ1dZN.js";import{u as X}from"./useFlyout-KZXqW5RR.js";import{a as Y}from"./LayoutContent.vue_vue_type_script_setup_true_lang-SafgfcNL.js";import{u as Z}from"./useBreadcrumb-DUhE6wbZ.js";import{f as G,c as u,a1 as J,m as k,D as _,y as r,I as f,q as l,Q as T,M as A,u as a,E as K}from"./vue-oicRkvo0.js";const W=c`
    mutation userCurrentAccessTokenDelete($tokenId: ID!) {
  userCurrentAccessTokenDelete(tokenId: $tokenId) {
    success
    errors {
      ...errors
    }
  }
}
    ${B}`;function ee(n={}){return E(W,n)}const b=c`
    fragment tokenAttributes on Token {
  id
  user {
    id
  }
  name
  preferences
  expiresAt
  lastUsedAt
  createdAt
}
    `,te=c`
    query userCurrentAccessTokenList {
  userCurrentAccessTokenList {
    ...tokenAttributes
  }
}
    ${b}`;function se(n={}){return I(te,{},n)}const ne=c`
    subscription userCurrentAccessTokenUpdates {
  userCurrentAccessTokenUpdates {
    tokens {
      ...tokenAttributes
    }
  }
}
    ${b}`,re={class:"flex flex-row gap-2"},oe={class:"mb-4"},ae=G({beforeRouteEnter(){const{canUseAccessToken:n}=j();return n.value?!0:R({type:V.AuthenticatedError,title:__("Forbidden"),message:__("Token-based API access has been disabled by the administrator."),statusCode:M.Forbidden})},__name:"PersonalSettingTokenAccess",setup(n){const{breadcrumbItems:y}=Z(__("Token Access")),C=X({name:"new-access-token",component:()=>x(()=>import("./PersonalSettingNewAccessTokenFlyout-DP1QVHe4.js"),__vite__mapDeps([0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28,29,30,31,32,33,34,35,36]))}),i=new N(se()),h=i.result(),m=i.loading();i.subscribeToMore({document:ne,updateQuery:(e,{subscriptionData:s})=>{var t;return(t=s.data)!=null&&t.userCurrentAccessTokenUpdates.tokens?{userCurrentAccessTokenList:s.data.userCurrentAccessTokenUpdates.tokens}:null}});const g=[{key:"name",label:__("Name"),truncate:!0},{key:"permissions",label:__("Permissions"),truncate:!0},{key:"createdAt",label:__("Created"),type:"timestamp"},{key:"expiresAt",label:__("Expires"),type:"timestamp"},{key:"lastUsedAt",label:__("Last Used"),type:"timestamp"}],{notify:v}=S(),{waitForVariantConfirmation:D}=q(),U=e=>{new Q(ee(()=>({variables:{tokenId:e.id},update(t){t.evict({id:t.identify(e)}),t.gc()}})),{errorNotificationMessage:__("The personal access token could not be deleted.")}).send().then(()=>{v({id:"personal-access-token-removed",type:F.Success,message:__("Personal access token has been deleted.")})})},w=async e=>{await D("delete")&&U(e)},P=[{key:"delete",label:__("Delete this access token"),icon:"trash3",variant:"danger",onClick:e=>{w(e)}}],d=u(()=>{var e;return(((e=h.value)==null?void 0:e.userCurrentAccessTokenList)||[]).map(s=>{var t,o;return{...s,permissions:((o=(t=s.preferences)==null?void 0:t.permission)==null?void 0:o.join(", "))||""}})}),$=u(()=>d.value.length>0),L=u(()=>[p.t("You can generate a personal access token for each application you use that needs access to the Zammad API."),p.t("Pick a name for the application, and we'll give you a unique token.")]);return(e,s)=>{const t=J("CommonBadge");return k(),_(Y,{"help-text":L.value,"show-inline-help":!$.value&&!a(m),"breadcrumb-items":a(y),width:"narrow"},{headerRight:r(()=>[f("div",re,[l(z,{"prefix-icon":"key",variant:"primary",size:"medium",onClick:s[0]||(s[0]=o=>a(C).open())},{default:r(()=>[T(A(e.$t("New Personal Access Token")),1)]),_:1})])]),default:r(()=>[l(O,{loading:a(m)},{default:r(()=>[f("div",oe,[l(H,{headers:g,items:d.value,actions:P,caption:e.$t("Personal Access Tokens"),class:"min-w-150"},{"item-suffix-name":r(({item:o})=>[o.current?(k(),_(t,{key:0,size:"medium",variant:"info",class:"ltr:ml-2 rtl:mr-2"},{default:r(()=>[T(A(e.$t("This device")),1)]),_:1})):K("",!0)]),_:1},8,["items","caption"])])]),_:1},8,["loading"])]),_:1},8,["help-text","show-inline-help","breadcrumb-items"])}}}),Te=Object.freeze(Object.defineProperty({__proto__:null,default:ae},Symbol.toStringTag,{value:"Module"}));export{Te as P,b as T,te as U};
//# sourceMappingURL=PersonalSettingTokenAccess-BWcVhEA-.js.map
