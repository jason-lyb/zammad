import{f as R,c as u,a1 as z,m as s,D as I,y as S,I as O,z as oe,Q as F,M as D,q as B,W as Q,L as q,C as X,Y as ne,w as M,r as U,aW as re,p as h,J as Z,x as ee,E as V,u as w,ac as Y,a7 as ae,H as ie,b as se,ap as le,ar as ue,aG as G,K as J}from"./vue-oicRkvo0.js";import{n as ce,u as de}from"./vendor-C11O1Xx8.js";import{u as me}from"./useStickyHeader-XWZvtRy7.js";import{O as ve,Y as T,i as N,e as pe,a as ye}from"./routes-CgLO9M4y.js";import{_ as H}from"./CommonLoader.vue_vue_type_script_setup_true_lang-BtrvaoyW.js";import{o as te}from"./mobile-Bk4bKGxF.js";import{u as fe,_ as we}from"./useTicketOverviews-BXq-2Pxm.js";import{_ as ge}from"./LayoutHeader.vue_vue_type_script_setup_true_lang-BeSNC-UK.js";import{u as be}from"./usePagination-CE_-FZed.js";import{u as ke,Q as he}from"./apollo-Cj5TVUDk.js";import{an as _e,bn as Ce,s as $e}from"./overviewAttributes.api-C09LSZ8O.js";import{_ as xe}from"./TicketItem.vue_vue_type_script_setup_true_lang-DIagoOiW.js";import"./commonjsHelpers-BosuxZz1.js";import"./vite-FJshFMF2.js";import"./lodash-pFOI14f-.js";import"./pwa-THoW_3xc.js";import"./add.api-CxwFhgGn.js";import"./datepicker-BBNcWeHz.js";import"./date-B2UyDZN7.js";import"./formkit-5nol1GBe.js";import"./useTicketCreateView-HCH46SPv.js";import"./CommonBackButton.vue_vue_type_script_setup_true_lang-DhwyOyd1.js";import"./CommonTicketPriorityIndicator.vue_vue_type_script_setup_true_lang-DZyaZr7q.js";import"./getUserDisplayName-Dg0PCZQh.js";const Be=["aria-expanded","onClick","onKeypress"],Oe=R({__name:"CommonSelectPill",props:{modelValue:{type:[String,Number,Boolean,Array,null]},options:{},placeholder:{},multiple:{type:Boolean},noClose:{type:Boolean},noOptionsLabelTranslation:{type:Boolean}},emits:["update:modelValue","select"],setup(_,{emit:C}){const a=_,$=C,g=u(()=>{const{placeholder:d,...i}=a;return i}),c=u(()=>{const d=a.options.find(i=>i.value===a.modelValue);return(d==null?void 0:d.label)||a.placeholder||""});return(d,i)=>{const t=z("CommonIcon");return s(),I(te,X(g.value,{"onUpdate:modelValue":i[0]||(i[0]=m=>$("update:modelValue",m)),onSelect:i[1]||(i[1]=m=>$("select",m))}),{default:S(({open:m,state:y})=>[O("button",{type:"button","aria-controls":"common-select","aria-owns":"common-select","aria-haspopup":"dialog","aria-expanded":y,class:"inline-flex w-auto cursor-pointer rounded-lg bg-gray-600 py-1 ltr:pr-1 ltr:pl-2 rtl:pr-2 rtl:pl-1",onClick:A=>m(),onKeypress:Q(q(A=>m(),["prevent"]),["space"])},[oe(d.$slots,"default",{},()=>[F(D(c.value),1)]),B(t,{class:"self-center",name:"caret-down",size:"tiny",decorative:""})],40,Be)]),_:3},16)}}}),Se=ce`
    query ticketsByOverviewSlim($overviewId: ID!, $orderBy: String, $orderDirection: EnumOrderDirection, $cursor: String, $showPriority: Boolean!, $showUpdatedBy: Boolean!, $pageSize: Int = 10, $withObjectAttributes: Boolean = false) {
  ticketsByOverview(
    overviewId: $overviewId
    orderBy: $orderBy
    orderDirection: $orderDirection
    after: $cursor
    first: $pageSize
  ) {
    totalCount
    edges {
      node {
        id
        internalId
        number
        title
        createdAt
        updatedAt
        updatedBy @include(if: $showUpdatedBy) {
          id
          fullname
        }
        customer {
          id
          firstname
          lastname
          fullname
        }
        organization {
          id
          name
        }
        state {
          id
          name
          stateType {
            id
            name
          }
        }
        group {
          id
          name
        }
        priority @include(if: $showPriority) {
          id
          name
          uiColor
          defaultCreate
        }
        objectAttributeValues @include(if: $withObjectAttributes) {
          ...objectAttributeValues
        }
        stateColorCode
      }
      cursor
    }
    pageInfo {
      endCursor
      hasNextPage
    }
  }
}
    ${ve}`;function De(_,C={}){return ke(Se,_,C)}const Ae=["aria-label","aria-busy"],Ie={key:0,class:"mb-4 px-3"},Pe={key:2,"aria-live":"polite",class:"px-4 py-3 text-center text-base"},Te={key:3,class:"px-4 py-3 text-center text-sm","aria-live":"polite"},K=10,Ve=R({__name:"TicketList",props:{overviewId:{},overviewTicketCount:{},maxCount:{},orderBy:{},hiddenColumns:{},orderDirection:{}},emits:["refetch"],setup(_,{emit:C}){const a=_,$=C,g=u(()=>({pageSize:K,overviewId:a.overviewId,orderBy:a.orderBy,orderDirection:a.orderDirection,showUpdatedBy:!a.hiddenColumns.includes("updated_by"),showPriority:!a.hiddenColumns.includes("priority")})),c=new he(De(g,{fetchPolicy:"cache-first",nextFetchPolicy:"cache-first"})),d=c.result(),i=c.loading();ne(()=>{$("refetch",i.value&&!!d.value)});const t=u(()=>{var n;return _e((n=d.value)==null?void 0:n.ticketsByOverview)}),m=u(()=>{var n;return((n=d.value)==null?void 0:n.ticketsByOverview.totalCount)||0}),y=be(c,"ticketsByOverview",K);M(()=>a.overviewTicketCount,n=>{n!==m.value&&c.refetch({...g.value,pageSize:K*y.currentPage})});const A=u(()=>!y.loadingNewPage&&!i.value&&y.hasNextPage&&t.value.length<a.maxCount),l=U(),v=async()=>{const n=Ce(l.value),r=n[n.length-2];await y.fetchNextPage(),r==null||r.focus({preventScroll:!0})};return re(window.document,async()=>{A.value&&await y.fetchNextPage()},{distance:150}),(n,r)=>{const f=z("CommonLink"),b=z("FormKit");return s(),I(H,{loading:!t.value.length&&w(i)},{default:S(()=>[t.value.length?(s(),h("section",{key:0,ref_key:"mainElement",ref:l,"aria-label":n.$t("%s tickets found",t.value.length),"aria-live":"polite","aria-busy":w(i)},[(s(!0),h(Z,null,ee(t.value,p=>(s(),I(f,{key:p.id,link:`/tickets/${p.internalId}`},{default:S(()=>[B(xe,{entity:p},null,8,["entity"])]),_:2},1032,["link"]))),128)),A.value?(s(),h("div",Ie,[B(b,{"wrapper-class":"mt-4 text-base flex grow justify-center items-center","input-class":"py-2 px-4 w-full h-14 text-white formkit-variant-primary:bg-gray-500 rounded-xl select-none",type:"submit",name:"load_more",onClick:v},{default:S(()=>[F(D(n.$t("load %s more",K)),1)]),_:1})])):V("",!0)],8,Ae)):V("",!0),w(y).loadingNewPage?(s(),I(H,{key:1,loading:"",class:"mt-4"})):V("",!0),t.value.length?t.value.length>=n.maxCount&&m.value>n.maxCount?(s(),h("div",Te,D(n.$t("The limit of %s displayable tickets was reached (%s remaining)",n.maxCount,m.value-t.value.length)),1)):V("",!0):(s(),h("div",Pe,D(n.$t("No entries")),1))]),_:1},8,["loading"])}}}),Ee=["aria-expanded","aria-label","onClick","onKeydown"],Le={class:"truncate"},Ne=["aria-pressed","onClick","onKeydown"],ze=R({__name:"TicketOrderBySelector",props:{orderBy:{},options:{},direction:{},label:{}},emits:["update:orderBy","update:direction"],setup(_,{emit:C}){const a=_,$=C,g=Y(a,"orderBy",$),c=Y(a,"direction",$),d=u(()=>N.t('Tickets are ordered by "%s" column (%s).',N.t(a.label),a.direction===T.Ascending?N.t("ascending"):N.t("descending"))),i=u(()=>[{value:T.Descending,label:__("descending"),icon:"arrow-down",iconProps:{class:{"text-blue":a.direction===T.Descending},size:"tiny"}},{value:T.Ascending,label:__("ascending"),icon:"arrow-up",iconProps:{class:[{"text-blue":a.direction===T.Ascending}],size:"tiny"}}]),t=U(),m=U(),y=ae("select"),A=(l,v)=>{var b,p,P,L,j;const{key:n}=l;if(!["ArrowUp","ArrowDown","ArrowLeft","ArrowRight"].includes(l.key))return;if($e(l),n==="ArrowUp"||n==="ArrowDown"){const E=((b=y.value)==null?void 0:b.getFocusableOptions())||[],e=n==="ArrowDown"?0:E.length-3;(p=E[e])==null||p.focus(),(P=E[e])==null||P.scrollIntoView({block:"nearest"});return}const r=v===1?0:1;(j=(((L=t.value)==null?void 0:L.querySelectorAll("button"))||[])[r])==null||j.focus()};return(l,v)=>{const n=z("CommonIcon");return s(),I(te,{ref:"select",modelValue:w(g),"onUpdate:modelValue":v[0]||(v[0]=r=>se(g)?g.value=r:null),options:l.options,"no-close":""},{default:S(({open:r,state:f})=>[O("button",{ref_key:"selectButton",ref:m,type:"button","aria-controls":"common-select","aria-owns":"common-select","aria-haspopup":"dialog","aria-expanded":f,"aria-label":d.value,class:"text-blue flex cursor-pointer items-center gap-1 overflow-hidden whitespace-nowrap",onClick:r,onKeydown:Q(q(r,["prevent"]),["space"])},[O("div",null,[B(n,{decorative:"",name:l.direction===w(T).Ascending?"arrow-up":"arrow-down",size:"tiny"},null,8,["name"])]),O("span",Le,D(l.$t(l.label)),1)],40,Ee)]),footer:S(()=>[O("div",{ref_key:"directionElement",ref:t,class:"flex gap-2 p-3 text-white"},[(s(!0),h(Z,null,ee(i.value,(r,f)=>(s(),h("button",{key:r.value,class:ie(["flex flex-1 cursor-pointer items-center justify-center rounded-md p-2",{"bg-gray-200 font-bold":r.value===l.direction}]),"aria-pressed":r.value===l.direction,type:"button",tabindex:"0",onClick:b=>c.value=r.value,onKeydown:[b=>A(b,f),Q(q(b=>c.value=r.value,["prevent"]),["space"])]},[r.icon?(s(),I(n,X({key:0,name:r.icon,decorative:"",class:"ltr:mr-1 rtl:ml-1",ref_for:!0},r.iconProps),null,16,["name"])):V("",!0),F(" "+D(l.$t(r.label)),1)],42,Ne))),128))],512)]),_:1},8,["modelValue","options"])}}}),je={key:0,class:"mb-3 flex items-center justify-between gap-2"},Ke={class:"max-w-[55vw] truncate"},Ue={class:"px-1"},Re={key:1,class:"flex items-center justify-center gap-2 p-4 text-center"},vt=R({__name:"TicketOverview",props:{overviewLink:{}},setup(_){const C=pe(),a=_,$=le(),g=ue(),{overviews:c,loading:d}=de(fe()),i=u(()=>c.value.map(e=>({value:e.link,label:`${N.t(e.name)} (${e.ticketCount})`}))),t=u(()=>c.value.find(e=>e.link===a.overviewLink)||null),m=u(()=>{var e;return((e=t.value)==null?void 0:e.link)||null}),y=ye(),A=u(()=>{var o;if(y.hasPermission(["ticket.agent"]))return[];const e=((o=t.value)==null?void 0:o.viewColumns.map(x=>x.key))||[];return["priority","updated_by"].filter(x=>!e.includes(x))}),l=e=>{const{query:o}=g;return $.replace({path:`/tickets/view/${e}`,query:o})};M([t,c],async([e])=>{if(!e&&c.value.length){const[o]=c.value;await l(o.link)}},{immediate:!0});const v=G("column",void 0),n=u(()=>{var e;return((e=t.value)==null?void 0:e.orderColumns.map(o=>({value:o.key,label:o.value||o.key})))||[]}),r=u(()=>{var e;return((e=t.value)==null?void 0:e.orderColumns.reduce((o,x)=>(o[x.key]=x.value||x.key,o),{}))||{}});M(t,()=>{v.value&&!r.value[v.value]&&(v.value=void 0)});const f=u({get:()=>{var e;return v.value&&r.value[v.value]?v.value:(e=t.value)==null?void 0:e.orderBy},set:e=>{var o;v.value=e!==((o=t.value)==null?void 0:o.orderBy)?e:void 0}}),b=u(()=>r.value[f.value||""]||""),p=G("direction",void 0);p.value&&!Object.values(T).includes(p.value)&&(p.value=void 0);const P=u({get:()=>{var e;return p.value?p.value:(e=t.value)==null?void 0:e.orderDirection},set:e=>{var o;p.value=e!==((o=t.value)==null?void 0:o.orderDirection)?e:void 0}}),{stickyStyles:L,headerElement:j}=me([d]),E=U(!1);return(e,o)=>{const x=z("CommonIcon");return s(),h("div",null,[O("header",{ref_key:"headerElement",ref:j,class:"border-b-[0.5px] border-white/10 bg-black px-4",style:J(w(L).header)},[B(ge,{"back-url":"/","container-tag":"div",class:"h-16 border-none first:px-0","back-avoid-home-button":"",refetch:E.value,title:e.__("Tickets")},{after:S(()=>[B(we,{class:"justify-self-end text-base"})]),_:1},8,["refetch","title"]),i.value.length?(s(),h("div",je,[B(Oe,{"model-value":m.value,options:i.value,"no-options-label-translation":"","onUpdate:modelValue":o[0]||(o[0]=k=>l(k))},{default:S(()=>{var k,W;return[O("span",Ke,D(e.$t((k=t.value)==null?void 0:k.name)),1),O("span",Ue," ("+D((W=t.value)==null?void 0:W.ticketCount)+") ",1)]}),_:1},8,["model-value","options"]),B(ze,{"order-by":f.value,"onUpdate:orderBy":o[1]||(o[1]=k=>f.value=k),direction:P.value,"onUpdate:direction":o[2]||(o[2]=k=>P.value=k),options:n.value,label:b.value},null,8,["order-by","direction","options","label"])])):V("",!0)],4),O("div",{style:J(w(L).body)},[w(d)||w(c).length?(s(),I(H,{key:0,loading:w(d)},{default:S(()=>[t.value&&f.value&&P.value?(s(),I(Ve,{key:0,"overview-id":t.value.id,"overview-ticket-count":t.value.ticketCount,"order-by":f.value,"order-direction":P.value,"max-count":w(C).config.ui_ticket_overview_ticket_limit,"hidden-columns":A.value,onRefetch:o[3]||(o[3]=k=>E.value=k)},null,8,["overview-id","overview-ticket-count","order-by","order-direction","max-count","hidden-columns"])):V("",!0)]),_:1},8,["loading"])):(s(),h("div",Re,[B(x,{class:"text-red",name:"close-small"}),F(" "+D(e.$t("Currently no overview is assigned to your roles.")),1)]))],4)])}}});export{vt as default};
//# sourceMappingURL=TicketOverview-90iQyL8A.js.map
