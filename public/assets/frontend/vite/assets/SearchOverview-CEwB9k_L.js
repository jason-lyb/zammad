import{f as w,t as M,c as g,m as o,p as c,I as l,q as f,Q as k,M as u,J as L,E as _,z as P,u as h,a1 as E,x as H,D as O,y as F,F as ae,ar as oe,ap as re,r as I,d as ie,a4 as le,k as ce,b5 as ue,w as de,K as x}from"./vue-oicRkvo0.js";import{i as pe,_ as me,bl as ye,bj as he}from"./overviewAttributes.api-C09LSZ8O.js";import{u as fe}from"./useStickyHeader-XWZvtRy7.js";import{a as D,ag as _e}from"./routes-CgLO9M4y.js";import{d as ve,Q as be}from"./apollo-Cj5TVUDk.js";import{_ as ge}from"./CommonButtonGroup.vue_vue_type_script_setup_true_lang-BTHDtl8G.js";import{b as ke}from"./mobile-Bk4bKGxF.js";import{u as Q,_ as $e}from"./TicketItem.vue_vue_type_script_setup_true_lang-DIagoOiW.js";import{n as Se}from"./vendor-C11O1Xx8.js";import{z as Ce}from"./lodash-pFOI14f-.js";import"./formkit-5nol1GBe.js";import"./vite-FJshFMF2.js";import"./pwa-THoW_3xc.js";import"./add.api-CxwFhgGn.js";import"./datepicker-BBNcWeHz.js";import"./date-B2UyDZN7.js";import"./commonjsHelpers-BosuxZz1.js";import"./CommonTicketPriorityIndicator.vue_vue_type_script_setup_true_lang-DZyaZr7q.js";import"./getUserDisplayName-Dg0PCZQh.js";const we={class:"flex ltr:pr-3 rtl:pl-3"},Le={class:"mt-4 flex w-14 justify-center"},ze={class:"flex flex-1 flex-col overflow-hidden border-b border-white/10 py-3 text-gray-100"},Ie={class:"truncate"},Ee={class:"mb-1 line-clamp-3 text-lg leading-5 font-bold whitespace-normal"},Oe={key:0,class:"text-gray truncate"},Ae=w({__name:"OrganizationItem",props:{entity:{}},setup(n){const r=n,{stringUpdated:t}=Q(M(r,"entity")),s=g(()=>{const{members:a}=r.entity;if(!a)return"";const y=a.edges.map(m=>m.node.fullname).filter(m=>m&&m!=="-").slice(0,2);let i=y.join(", ");const d=a.totalCount-y.length;return d>0&&(i+=`, +${d}`),i});return(a,y)=>{var i,d;return o(),c("div",we,[l("div",Le,[f(pe,{"aria-hidden":"true",class:"bg-gray",entity:a.entity},null,8,["entity"])]),l("div",ze,[l("span",Ie,[k(u(((i=a.entity.ticketsCount)==null?void 0:i.open)===1?`1 ${a.$t("ticket")}`:a.$t("%s tickets",((d=a.entity.ticketsCount)==null?void 0:d.open)||0))+" ",1),s.value?(o(),c(L,{key:0},[k(" · "+u(s.value),1)],64)):_("",!0)]),l("span",Ee,[P(a.$slots,"default",{},()=>[k(u(a.entity.name),1)])]),h(t)?(o(),c("div",Oe,u(h(t)),1)):_("",!0)])])}}}),Be={model:"Organization",headerLabel:__("Organizations"),searchLabel:__('Organizations with "%s"'),component:Ae,link:"/organizations/#{internalId}",permissions:["ticket.agent"],order:300,icon:{name:"organization",size:"base"},iconBg:"bg-orange"},Te={model:"Ticket",headerLabel:__("Tickets"),searchLabel:__('Tickets with "%s"'),component:$e,link:"/tickets/#{internalId}",permissions:["ticket.agent","ticket.customer"],icon:{name:"all-tickets",size:"base"},iconBg:"bg-blue",order:100},Re={class:"flex ltr:pr-3 rtl:pl-3"},je={class:"mt-4 flex w-14 justify-center"},Ue={class:"flex flex-1 flex-col overflow-hidden border-b border-white/10 py-3 text-gray-100"},Ne={class:"truncate"},Ve={class:"mb-1 line-clamp-3 text-lg leading-5 font-bold whitespace-normal"},qe={key:0,class:"truncate"},xe=w({__name:"UserItem",props:{entity:{}},setup(n){const r=n,{stringUpdated:t}=Q(M(r,"entity"));return(s,a)=>{var y,i;return o(),c("div",Re,[l("div",je,[f(me,{"aria-hidden":"true",entity:s.entity},null,8,["entity"])]),l("div",Ue,[l("span",Ne,[k(u(((y=s.entity.ticketsCount)==null?void 0:y.open)===1?`1 ${s.$t("ticket")}`:s.$t("%s tickets",((i=s.entity.ticketsCount)==null?void 0:i.open)||0))+" ",1),s.entity.organization?(o(),c(L,{key:0},[k(" · "+u(s.entity.organization.name),1)],64)):_("",!0)]),l("span",Ve,[P(s.$slots,"default",{},()=>[k(u(s.entity.firstname)+" "+u(s.entity.lastname),1)])]),h(t)?(o(),c("div",qe,u(h(t)),1)):_("",!0)])])}}}),Me={model:"User",headerLabel:__("Users"),searchLabel:__('Users with "%s"'),component:xe,order:200,link:"/users/#{internalId}",permissions:["ticket.agent"],icon:{name:"person",size:"base"},iconBg:"bg-pink"},Pe=Object.assign({"./organization.ts":Be,"./ticket.ts":Te,"./user.ts":Me}),He=Object.entries(Pe).map(([n,r])=>[n.replace(/^.*\/([^/]+)\.ts$/,"$1"),r]).sort(([,n],[,r])=>n.order-r.order),A=()=>{const{hasPermission:n}=D();return He.filter(([,t])=>n(t.permissions)).reduce((t,[s,a])=>(t[s]=a,t),{})},Fe=w({__name:"SearchResults",props:{type:{},data:{}},setup(n){const r=n,t=A(),s=g(()=>t[r.type]);return(a,y)=>{const i=E("CommonLink");return o(!0),c(L,null,H(a.data,d=>(o(),O(i,{key:d.id,link:h(ye)(s.value.link,d,!0)},{default:F(()=>[(o(),O(ae(s.value.component),{entity:d},null,8,["entity"]))]),_:2},1032,["link"]))),128)}}}),De=Se`
    query search($search: String!, $onlyIn: EnumSearchableModels!, $limit: Int = 30) {
  search(search: $search, onlyIn: $onlyIn, limit: $limit) {
    totalCount
    items {
      ... on Ticket {
        id
        internalId
        title
        number
        state {
          id
          name
        }
        priority {
          name
          defaultCreate
          uiColor
        }
        customer {
          id
          internalId
          fullname
        }
        updatedAt
        updatedBy {
          id
          fullname
        }
        stateColorCode
      }
      ... on User {
        id
        internalId
        firstname
        lastname
        image
        active
        outOfOffice
        outOfOfficeStartAt
        outOfOfficeEndAt
        vip
        organization {
          id
          internalId
          name
        }
        updatedAt
        updatedBy {
          id
          fullname
        }
        ticketsCount {
          open
          closed
        }
      }
      ... on Organization {
        id
        internalId
        members(first: 2) {
          edges {
            node {
              id
              fullname
            }
          }
          totalCount
        }
        active
        name
        vip
        updatedAt
        updatedBy {
          id
          fullname
        }
        ticketsCount {
          open
          closed
        }
      }
    }
  }
}
    `;function Qe(n,r={}){return ve(De,n,r)}const Ge={class:"flex p-4"},Xe={class:"sr-only"},Je={key:1,class:"mt-8 px-4"},Ke={key:0,class:"flex h-14 w-full items-center justify-center"},We=["aria-busy"],Ye={key:2,class:"px-4 pt-4"},Ze={key:3,class:"px-4 pt-8"},et={class:"text-white/50"},tt={class:"pt-3"},st=["onClick"],nt={class:"text-left text-base"},at={key:0},ot={beforeRouteEnter(n){const{type:r}=n.params,t=A();if(!r){const s=Object.entries(t);return s.length===1?{...n,params:{type:s[0][0]}}:void 0}if(Array.isArray(r)||!t[r])return{...n,params:{}}}},Lt=w({...ot,__name:"SearchOverview",props:{type:{}},setup(n){const t=n,s=oe(),a=re(),y=A(),i=I(String(s.query.search||"")),d=I(i.value),m=g(()=>d.value.length>=1),$=ie({}),{userId:G}=D(),v=le(`${G}-recentSearches`,[]),X=g(()=>{var e;return t.type?(e=y[t.type])==null?void 0:e.model:_e.Ticket}),S=new be(Qe(()=>({search:d.value,onlyIn:X.value}),()=>({enabled:m.value}))),z=S.loading();S.watchOnResult(e=>{t.type&&e.search&&($[t.type]=e.search.items)});const J=e=>a.replace({query:{...s.query,...e}}),B=I(),T=()=>{var e;return(e=B.value)==null?void 0:e.focus()},R=async e=>{await a.replace({params:{type:e}});const p=document.querySelector(`[data-value="${e}"]`);p==null||p.focus()};ce(()=>{T()});const C=async e=>{d.value=e,J({search:e}),!(!m.value||!t.type)&&(v.value=v.value.filter(p=>p!==e),v.value.push(e),v.value.length>5&&v.value.shift(),S.isFirstRun()&&S.load())},K=Ce(C,600),{ignoreUpdates:W}=ue(i,async e=>{if(!e||!t.type){await C(e);return}await K(e)});de(()=>t.type,()=>C(i.value),{immediate:!0});const Y=async e=>{W(()=>{i.value=e}),T(),await C(e)},j=Object.entries(y).map(([e,p])=>({name:e,...p})),Z=j.map(e=>({value:e.name,label:e.headerLabel})),ee=g(()=>j.map(e=>({label:e.searchLabel,labelPlaceholder:[i.value],type:"link",value:e.name,icon:e.icon,iconBg:e.iconBg,onClick:()=>R(e.name)}))),te=g(()=>{var e;return z.value?!1:t.type&&!((e=$[t.type])!=null&&e.length)||!m.value}),{headerElement:se,stickyStyles:U}=fe([z,()=>!!t.type]),N=g(()=>z.value?!t.type||!$[t.type]:!1);return(e,p)=>{var q;const ne=E("CommonLink"),V=E("CommonIcon");return o(),c("div",null,[l("header",{ref_key:"headerElement",ref:se,class:"bg-black",style:x(h(U).header)},[l("div",Ge,[f(he,{ref_key:"searchInput",ref:B,modelValue:i.value,"onUpdate:modelValue":p[0]||(p[0]=b=>i.value=b),"wrapper-class":"flex-1",class:"!h-10","aria-label":e.$t("Enter search and select a type to search for")},null,8,["modelValue","aria-label"]),f(ne,{link:"/",class:"text-blue flex items-center justify-center text-base ltr:pl-3 rtl:pr-3"},{default:F(()=>[k(u(e.$t("Cancel")),1)]),_:1})]),l("h1",Xe,u(e.$t("Search")),1),e.type?(o(),O(ge,{key:0,class:"border-b border-[rgba(255,255,255,0.1)] px-4 pb-4",as:"tabs",options:h(Z),"model-value":e.type,"onUpdate:modelValue":p[1]||(p[1]=b=>R(b))},null,8,["options","model-value"])):m.value?(o(),c("div",Je,[f(ke,{"header-label":e.__("Search for…"),items:ee.value},null,8,["header-label","items"])])):_("",!0)],4),l("div",{style:x(h(U).body)},[N.value?(o(),c("div",Ke,[f(V,{name:"loading",animation:"spin"})])):m.value&&e.type&&((q=$[e.type])!=null&&q.length)?(o(),c("div",{key:1,id:"search-results","aria-live":"polite",role:"tabpanel","aria-busy":N.value},[f(Fe,{data:$[e.type],type:e.type},null,8,["data","type"])],8,We)):m.value&&e.type?(o(),c("div",Ye,u(e.$t("No entries")),1)):_("",!0),te.value?(o(),c("div",Ze,[l("div",et,u(e.$t("Recent searches")),1),l("ul",tt,[(o(!0),c(L,null,H([...h(v)].reverse(),b=>(o(),c("li",{key:b,class:"pb-4"},[l("button",{type:"button",class:"flex items-center",onClick:rt=>Y(b)},[l("span",null,[f(V,{name:"clock",size:"small",class:"mx-2 text-white/50",decorative:""})]),l("span",nt,u(b),1)],8,st)]))),128)),h(v).length?_("",!0):(o(),c("li",at,u(e.$t("No recent searches")),1))])])):_("",!0)],4)])}}});export{Lt as default};
//# sourceMappingURL=SearchOverview-CEwB9k_L.js.map
