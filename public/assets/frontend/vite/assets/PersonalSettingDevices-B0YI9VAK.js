import{e as L,u as A,Q as M,M as $,N,c as Q}from"./apollo-Cj5TVUDk.js";import{X as I,a2 as x}from"./overviewAttributes.api-C09LSZ8O.js";import{F as B,i as T}from"./routes-CgLO9M4y.js";import{k as F,d as V}from"./desktop-l0eJ1dZN.js";import{a as q}from"./LayoutContent.vue_vue_type_script_setup_true_lang-SafgfcNL.js";import{u as H}from"./useBreadcrumb-DUhE6wbZ.js";import{n as o}from"./vendor-C11O1Xx8.js";import{f as S,c,a1 as E,m as u,D as m,y as s,q as d,I as P,Q as R,M as X,E as Z,u as l}from"./vue-oicRkvo0.js";import"./lodash-pFOI14f-.js";import"./formkit-5nol1GBe.js";import"./vite-FJshFMF2.js";import"./Form.vue_vue_type_script_setup_true_lang-B6L-6HzY.js";import"./FormGroup.vue_vue_type_script_setup_true_lang-DIx-HUKU.js";import"./useForm-CUKec4n5.js";import"./useCopyToClipboard-CjkPg__g.js";import"./theme-Bv2ClBzZ.js";import"./datepicker-BBNcWeHz.js";import"./date-B2UyDZN7.js";import"./autocompleteTags.api-CG5-cm_A.js";import"./autocompleteSearchTicket.api-DfOQWGlO.js";import"./ticketUpdates.api-BhGIG_Ti.js";import"./ticketAttributes.api-rqx5ITab.js";import"./useTicketCreateArticleType-D7iVcJ_6.js";import"./types-Cu-Nkl7K.js";import"./useTicketCreateView-HCH46SPv.js";import"./commonjsHelpers-BosuxZz1.js";import"./LayoutMain.vue_vue_type_script_setup_true_lang-DIWzj6-0.js";import"./LayoutSidebar.vue_vue_type_script_setup_true_lang-BO1pkKrb.js";import"./useResizeGridColumns-CieKHty_.js";const j=o`
    mutation userCurrentDeviceDelete($deviceId: ID!) {
  userCurrentDeviceDelete(deviceId: $deviceId) {
    success
    errors {
      ...errors
    }
  }
}
    ${I}`;function z(i={}){return L(j,i)}const p=o`
    fragment userDeviceAttributes on UserDevice {
  id
  userId
  name
  os
  browser
  location
  deviceDetails
  locationDetails
  fingerprint
  userAgent
  ip
  createdAt
  updatedAt
}
    `,G=o`
    query userCurrentDeviceList {
  userCurrentDeviceList {
    ...userDeviceAttributes
  }
}
    ${p}`;function J(i={}){return A(G,{},i)}const K=o`
    subscription userCurrentDevicesUpdates {
  userCurrentDevicesUpdates {
    devices {
      ...userDeviceAttributes
    }
  }
}
    ${p}`,O={class:"mb-4"},Ae=S({__name:"PersonalSettingDevices",setup(i){const{breadcrumbItems:v}=H(__("Devices")),{notify:f}=Q(),{fingerprint:D}=B(),n=new M(J()),_=n.result(),b=n.loading();n.subscribeToMore({document:K,updateQuery:(e,{subscriptionData:t})=>{var r;return(r=t.data)!=null&&r.userCurrentDevicesUpdates.devices?{userCurrentDeviceList:t.data.userCurrentDevicesUpdates.devices}:null}});const{waitForVariantConfirmation:g}=x(),C=e=>{new $(z(()=>({variables:{deviceId:e.id},update(r){r.evict({id:r.identify(e)}),r.gc()}})),{errorNotificationMessage:__("The device could not be deleted.")}).send().then(()=>{f({id:"device-revoked",type:N.Success,message:__("Device has been revoked.")})})},y=async e=>{await g("delete")&&C(e)},h=[{key:"name",label:__("Name"),truncate:!0},{key:"location",label:__("Location"),truncate:!0},{key:"updatedAt",label:__("Most recent activity"),type:"timestamp"}],U=[{key:"delete",label:__("Delete this device"),icon:"trash3",variant:"danger",show:e=>!(e!=null&&e.current),onClick:e=>{y(e)}}],w=c(()=>{var e;return(((e=_.value)==null?void 0:e.userCurrentDeviceList)||[]).map(t=>({...t,current:t.fingerprint&&t.fingerprint===D.value}))}),a=c(()=>T.t("All computers and browsers from which you logged in to Zammad appear here."));return(e,t)=>{const r=E("CommonBadge");return u(),m(q,{"breadcrumb-items":l(v),"help-text":a.value,width:"narrow","provide-default":""},{default:s(()=>[d(V,{loading:l(b)},{default:s(()=>[P("div",O,[d(F,{caption:e.$t("Used devices"),headers:h,items:w.value,actions:U,class:"min-w-150","aria-label":a.value},{"item-suffix-name":s(({item:k})=>[k.current?(u(),m(r,{key:0,variant:"info",class:"ltr:ml-2 rtl:mr-2"},{default:s(()=>[R(X(e.$t("This device")),1)]),_:1})):Z("",!0)]),_:1},8,["caption","items","aria-label"])])]),_:1},8,["loading"])]),_:1},8,["breadcrumb-items","help-text"])}}});export{Ae as default};
//# sourceMappingURL=PersonalSettingDevices-B0YI9VAK.js.map
