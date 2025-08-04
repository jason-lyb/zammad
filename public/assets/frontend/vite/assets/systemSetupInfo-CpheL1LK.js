import{a4 as I,c}from"./vue-oicRkvo0.js";import{n as p,q as v}from"./vendor-C11O1Xx8.js";import{e as g,W as o,V as n}from"./routes-CgLO9M4y.js";import{e as k,d as M,Q as $,M as h}from"./apollo-Cj5TVUDk.js";import{X as w}from"./overviewAttributes.api-C09LSZ8O.js";const P=p`
    mutation systemSetupUnlock($value: String!) {
  systemSetupUnlock(value: $value) {
    success
    errors {
      ...errors
    }
  }
}
    ${w}`;function U(e={}){return k(P,e)}const D=p`
    query systemSetupInfo {
  systemSetupInfo {
    status
    type
  }
}
    `;function Q(e={}){return M(D,{},e)}const R=v("systemSetupInfo",()=>{const e=I("systemSetupInfo",{}),m=new $(Q({fetchPolicy:"network-only"})),i=async()=>{var s;const t=(s=(await m.query()).data)==null?void 0:s.systemSetupInfo;t&&(e.value={...e.value,type:e.value.type===n.Import&&t.type===n.Manual?e.value.type:t.type,status:t.status})},r=g(),l=()=>{const u="/guided-setup/import";let t=r.config.import_backend;if(r.config.import_mode)return`${u}/${t}/status`;e.value.importSource&&(t=e.value.importSource);const s=t?`/${t}`:"";return`${u}${s}`},S=(u,t,s)=>{if(!u||u===o.New)return"/guided-setup";if(u===o.Automated)return"/guided-setup/automated";if(u===o.InProgress){if(!t)return"/guided-setup";if(t===n.Manual)return s&&t==="manual"?"/guided-setup/manual":"/guided-setup";if(t===n.Import)return l()}return"/guided-setup"},a=c(()=>{const{status:u,type:t,lockValue:s}=e.value;return S(u,t||"",s)}),y=u=>e.value.status===o.Automated||e.value.type===n.Import&&e.value.importSource?!u.startsWith(a.value):u!==a.value,f=c(()=>{const{status:u}=e.value;return u===o.Done||r.config.system_init_done}),d=c(()=>{const{status:u,lockValue:t}=e.value;return u===o.InProgress&&!t});return{redirectPath:a,redirectNeeded:y,setSystemSetupInfo:i,systemSetupUnlock:u=>{const{lockValue:t}=e.value;if(!t)return;new h(U({variables:{value:t}})).send().then(()=>{e.value={},u()}).catch(()=>{})},systemSetupInfo:e,systemSetupDone:f,systemSetupAlreadyStarted:d}});export{R as u};
//# sourceMappingURL=systemSetupInfo-CpheL1LK.js.map
