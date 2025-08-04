import{u as c}from"./useTicketCreateView-HCH46SPv.js";import{f as m,a1 as o,u,m as l,p as k,q as n,y as d,E as C,k as v,aO as p}from"./vue-oicRkvo0.js";import{d as f,Q as _}from"./apollo-Cj5TVUDk.js";import{n as w}from"./vendor-C11O1Xx8.js";import{f as T}from"./mobile-Bk4bKGxF.js";const y={key:0,class:"flex cursor-pointer items-center justify-end"},V=m({__name:"CommonTicketCreateLink",setup(t){const{ticketCreateEnabled:e}=c();return(r,g)=>{const s=o("CommonIcon"),a=o("CommonLink");return u(e)?(l(),k("div",y,[n(a,{link:"/tickets/create","aria-label":r.$t("Create new ticket")},{default:d(()=>[n(s,{name:"add",size:"small",decorative:""})]),_:1},8,["aria-label"])])):C("",!0)}}}),O=w`
    query ticketOverviewTicketCount($ignoreUserConditions: Boolean!) {
  ticketOverviews(ignoreUserConditions: $ignoreUserConditions) {
    id
    ticketCount
  }
}
    `;function L(t,e={}){return f(O,t,e)}const i=6e4,b=()=>{const t=T(),e=new _(L({ignoreUserConditions:!1},{pollInterval:i}));return v(()=>{t.loading?p(()=>e.load(),i):e.load()}),t};export{V as _,b as u};
//# sourceMappingURL=useTicketOverviews-BXq-2Pxm.js.map
