import{q as U,i as _}from"./routes-CgLO9M4y.js";import{u as K,Q as W}from"./apollo-Cj5TVUDk.js";import{d as X,r as Y}from"./desktop-l0eJ1dZN.js";import{_ as ee}from"./CommonFlyout.vue_vue_type_script_setup_true_lang-Cr1ukr3s.js";import{n as te}from"./vendor-C11O1Xx8.js";import{bo as j,aI as O,at as ne,_ as ae,b7 as re}from"./overviewAttributes.api-C09LSZ8O.js";import{_ as A}from"./CommonTranslateRenderer.vue_vue_type_script_setup_true_lang-B8a5B2Eg.js";import{f,m as o,p as u,q as b,a1 as T,D as c,y as g,Q as y,M as C,E as v,c as S,u as k,H as I,F as oe,I as R,a7 as ie,w as F,n as se,a8 as ce,J as x,x as H,U as le}from"./vue-oicRkvo0.js";import{A as E}from"./lodash-pFOI14f-.js";import"./vite-FJshFMF2.js";import"./Form.vue_vue_type_script_setup_true_lang-B6L-6HzY.js";import"./formkit-5nol1GBe.js";import"./FormGroup.vue_vue_type_script_setup_true_lang-DIx-HUKU.js";import"./useForm-CUKec4n5.js";import"./useCopyToClipboard-CjkPg__g.js";import"./theme-Bv2ClBzZ.js";import"./datepicker-BBNcWeHz.js";import"./date-B2UyDZN7.js";import"./autocompleteTags.api-CG5-cm_A.js";import"./autocompleteSearchTicket.api-DfOQWGlO.js";import"./ticketUpdates.api-BhGIG_Ti.js";import"./ticketAttributes.api-rqx5ITab.js";import"./useTicketCreateArticleType-D7iVcJ_6.js";import"./types-Cu-Nkl7K.js";import"./useTicketCreateView-HCH46SPv.js";import"./commonjsHelpers-BosuxZz1.js";import"./CommonOverlayContainer.vue_vue_type_script_setup_true_lang-CxyKmNUC.js";import"./LayoutSidebar.vue_vue_type_script_setup_true_lang-BO1pkKrb.js";import"./useFlyout-KZXqW5RR.js";const de=te`
    query ticketHistory($ticketId: ID, $ticketInternalId: Int, $ticketNumber: String) {
  ticketHistory(
    ticket: {ticketId: $ticketId, ticketInternalId: $ticketInternalId, ticketNumber: $ticketNumber}
  ) {
    createdAt
    records {
      issuer {
        ... on User {
          id
          internalId
          firstname
          lastname
          fullname
          phone
          email
          image
        }
        ... on Trigger {
          id
          name
        }
        ... on Job {
          id
          name
        }
        ... on PostmasterFilter {
          id
          name
        }
        ... on ObjectClass {
          klass
          info
        }
      }
      events {
        createdAt
        action
        object {
          ... on Checklist {
            id
            name
          }
          ... on ChecklistItem {
            id
            text
            checked
          }
          ... on Group {
            id
            name
          }
          ... on Mention {
            id
            user {
              id
              fullname
            }
          }
          ... on Organization {
            id
            name
          }
          ... on Ticket {
            id
            internalId
            number
            title
          }
          ... on TicketArticle {
            id
            body
          }
          ... on TicketSharedDraftZoom {
            id
          }
          ... on User {
            id
            fullname
          }
          ... on ObjectClass {
            klass
            info
          }
        }
        attribute
        changes
      }
    }
  }
}
    `;function me(e={},t={}){return K(de,e,t)}const V={TicketArticle:__("Article"),"Ticket::Article":__("Article"),TicketSharedDraftZoom:__("Shared Draft"),"Ticket::SharedDraftZoom":__("Shared Draft"),ChecklistItem:__("Checklist Item"),"Checklist::Item":__("Checklist Item")},q=e=>((e==null?void 0:e.__typename)==="ObjectClass"?e.klass:e==null?void 0:e.__typename)||__("Unknown"),L=e=>{const t=q(e);return V[t]||t},ue={name:"added",actionName:"added",content:e=>{var n;const{attribute:t}=e;return{entityName:L(e.object),attributeName:t?j(t):"",details:((n=e.changes)==null?void 0:n.to)||""}}},_e={name:"checklist-item-checked",actionName:e=>{var t;return((t=e.changes)==null?void 0:t.to)==="true"?"checked":"unchecked"},content:e=>{var t;return{entityName:__("Checklist Item"),details:((t=e.changes)==null?void 0:t.from)||""}}},pe={name:"created-mention",actionName:"created",content:e=>{var t;return{description:__("Mention for"),details:((t=e.object)==null?void 0:t.__typename)==="User"?e.object.fullname:"-"}}},z=f({__name:"HistoryEventDetailsReaction",props:{event:{}},setup(e){const t={"removed-reaction":__("Removed reaction from message %s from %s"),"changed-reaction":__("Changed reaction on message %s from %s"),"changed-reaction-to":__("Changed reaction to %s on message %s from %s"),reacted:__("Reacted to message %s from %s"),"reacted-with":__("Reacted with %s to message %s from %s")},n={type:"label",props:{size:"medium",class:"cursor-text rounded bg-neutral-200 px-0.5 font-mono text-black dark:bg-gray-400 dark:text-white"},content:e.event.details||""},r={type:"label",props:{size:"medium"},content:e.event.additionalDetails||""},a={type:"label",props:{size:"medium"},content:e.event.description||""},i={"changed-reaction":[n,r],"changed-reaction-to":[a,n,r],reacted:[n,r],"reacted-with":[a,n,r],"removed-reaction":[n,r]};return(d,m)=>(o(),u("span",null,[b(A,{class:"text-sm leading-snug text-gray-100 dark:text-neutral-400",source:t[d.event.actionName],placeholders:i[d.event.actionName]},null,8,["source","placeholders"])]))}}),ge={name:"created",actionName:e=>{var n;return!e.attribute||e.attribute!=="reaction"?"created":((n=e.changes)==null?void 0:n.to).length>0?"reacted-with":"reacted"},content:e=>{var n,r;if(e.attribute&&e.attribute==="reaction"){const a=e.object;return{description:(n=e.changes)==null?void 0:n.to,details:O(a.body),additionalDetails:e.changes.from,component:z}}const t=((r=e.changes)==null?void 0:r.to)||"";return{entityName:L(e.object),details:t}}},ke=f({__name:"HistoryEventDetailsEmail",props:{event:{}},setup(e){return(t,n)=>(o(),u("span",null,[b(A,{class:"text-sm leading-snug text-gray-100 dark:text-neutral-400",source:t.__("Email sent to %s"),placeholders:[{type:"label",props:{size:"medium",class:"cursor-text rounded bg-neutral-200 px-0.5 font-mono text-black dark:bg-gray-400 dark:text-white"},content:t.event.details||""}]},null,8,["source","placeholders"])]))}}),be={name:"email",actionName:"email",component:ke,content:e=>{var t;return{details:(t=e.changes)==null?void 0:t.to}}},J=f({__name:"HistoryEventDetailsMerge",props:{event:{}},setup(e){const t={"received-merge":__("Merged %s into this ticket"),"merged-into":__("Merged this ticket into %s")};return(n,r)=>(o(),u("span",null,[b(A,{class:"text-sm leading-snug text-gray-100 dark:text-neutral-400",source:t[n.event.actionName],placeholders:[{type:"link",props:{link:n.event.link,size:"medium",class:"text-blue-800 hover:underline"},content:n.event.details||""}]},null,8,["source","placeholders"])]))}}),fe={name:"merged-into",actionName:"merged-into",component:J,content:e=>{const t=e.object;return{details:`#${t.number}`,link:`/tickets/${t.internalId}`}}},he={name:"notification",actionName:"notification",content:e=>{var r,a,i;const n=((r=e.changes)==null?void 0:r.to).match(/^(?<email>[^(]+)\((?<details>[^)]+)\)$/);return{details:(a=n==null?void 0:n.groups)==null?void 0:a.email,additionalDetails:(i=n==null?void 0:n.groups)==null?void 0:i.details}}},ye={name:"received-merge",actionName:"received-merge",component:J,content:e=>{const t=e.object;return{details:`#${t.number}`,link:`/tickets/${t.internalId}`}}},ve={name:"removed-mention",actionName:"removed",content:e=>{var t;return{description:__("Mention for"),details:((t=e.object)==null?void 0:t.__typename)==="User"?e.object.fullname:"-"}}},Ne={name:"removed",actionName:e=>e.attribute&&e.attribute==="reaction"?"removed-reaction":"removed",content:e=>{var n;if(e.attribute&&e.attribute==="reaction"){const r=e.object;return{details:O(r.body),additionalDetails:e.changes.from,component:z}}const t=((n=e.changes)==null?void 0:n.to)||"";return{entityName:L(e.object),attributeName:e.attribute?j(e.attribute):"",details:t}}},D=f({__name:"HistoryEventDetailsTimeTriggerPerformed",props:{event:{}},setup(e){return(t,n)=>{const r=T("CommonLabel");return o(),u("span",null,[t.event.description?(o(),c(r,{key:0,class:"text-gray-100 dark:text-neutral-400"},{default:g(()=>[y(C(t.$t(t.event.description)),1)]),_:1})):v("",!0)])}}}),$e={name:"time-trigger-performed",actionName:"triggered",content:e=>{var t;switch((t=e.changes)==null?void 0:t.from){case"reminder_reached":return{description:__("Triggered because pending reminder was reached"),component:D};case"escalation":return{description:__("Triggered because ticket was escalated"),component:D};case"escalation_warning":return{description:__("Triggered because ticket will escalate soon"),component:D};default:return{description:__("Triggered because time event was reached"),component:D}}}},M=e=>/^(?:\d{4}-\d{2}-\d{2}|(?:\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}Z)|(?:\d{4}-\d{2}-\d{2} \d{2}:\d{2}:\d{2} UTC))$/.test(e)?!Number.isNaN(Date.parse(String(e))):!1,B=e=>/^\d{4}-\d{2}-\d{2}$/.test(e),Ce={name:"updated",actionName:e=>{var n;return!e.attribute||e.attribute!=="reaction"?"updated":((n=e.changes)==null?void 0:n.to).length>0?"changed-reaction-to":"changed-reaction"},content:e=>{var m,N,h,l;const{attribute:t}=e;if(t==="reaction"){const p=e.object;return{description:(m=e.changes)==null?void 0:m.to,details:O(p.body),additionalDetails:e.changes.from,component:z}}const n=q(e.object);let r=((N=e.changes)==null?void 0:N.from)||"-",a=((h=e.changes)==null?void 0:h.to)||"-",i=t,d=!1;if(n in U){const{attributesLookup:p}=ne(U[n]);if(t){const s=p.value.get(`${t}_id`)||p.value.get(t);d=((l=s==null?void 0:s.dataOption)==null?void 0:l.translate)??!1,s!=null&&s.display&&(i=s==null?void 0:s.display)}}if(M(r)||M(a)){const p=B(r)||B(a)?"date":"dateTime";r!=="-"&&(r=_[p](r)),a!=="-"&&(a=_[p](a))}else d&&(r=_.t(r),a=_.t(a));return t==="group"&&(r=r.replace("::"," › "),a=a.replace("::"," › ")),{entityName:V[n]||n,attributeName:i,details:r,additionalDetails:a,showSeparator:r.length>0&&a.length>0}}},Te=Object.assign({"./added.ts":ue,"./checklist-item-checked.ts":_e,"./created-mention.ts":pe,"./created.ts":ge,"./email.ts":be,"./merged-into.ts":fe,"./notification.ts":he,"./received-merge.ts":ye,"./removed-mention.ts":ve,"./removed.ts":Ne,"./time-trigger-performed.ts":$e,"./updated.ts":Ce}),De=Object.entries(Te).reduce((e,[t,n])=>(e[n.name]=n,e),{}),Q=De,P={Job:__("Scheduler"),PostmasterFilter:__("Postmaster Filter"),Trigger:__("Trigger")},Z=()=>{const e=a=>a.__typename!=="User",t=a=>e(a)?!1:a.internalId===1;return{getIssuerName:a=>{switch(a.__typename){case"User":return t(a)?_.t("System"):a.fullname;case"Job":case"PostmasterFilter":case"Trigger":return`${_.t(P[a.__typename])}: ${a.name}`;case"ObjectClass":return`${_.t(P[a.klass])}: ${a.info}`;default:return _.t("Unknown")}},issuedBySystemService:e,issuedBySystemUser:t,getEventOutput:a=>{if(!a.action||!Q[E(a.action)])throw new Error("Event action is missing or not found in event actions lookup!");const i=Q[E(a.action)],d=typeof i.actionName=="function"?i.actionName(a):i.actionName;return{component:i.component,...i.content(a),actionName:E(d)}}}},Ie=f({__name:"HistoryEventDetails",props:{event:{}},setup(e){const t=S(()=>e.event.description?_.t(e.event.description):[e.event.entityName,e.event.attributeName].filter(n=>!!n).map(n=>_.t(n)).join(" ")||null);return(n,r)=>{const a=T("CommonLabel");return o(),u("span",null,[b(a,{class:"text-gray-100 ltr:mr-1 rtl:ml-1 dark:text-neutral-400"},{default:g(()=>[y(C(k(j)(n.$t(n.event.actionName))),1)]),_:1}),t.value?(o(),c(a,{key:0,class:"text-gray-100 dark:text-neutral-400"},{default:g(()=>[y(C(t.value),1)]),_:1})):v("",!0),n.event.details?(o(),c(a,{key:1,class:I(["cursor-text rounded bg-neutral-200 px-0.5 font-mono text-black dark:bg-gray-400 dark:text-white",{"ltr:mr-1 rtl:ml-1":n.event.showSeparator||n.event.additionalDetails,"ltr:ml-1 rtl:mr-1":t.value}])},{default:g(()=>[y(C(n.event.details),1)]),_:1},8,["class"])):v("",!0),n.event.showSeparator&&n.event.details&&n.event.additionalDetails?(o(),c(a,{key:2,class:I(["text-gray-100 dark:text-neutral-400",{"ltr:mr-1 rtl:ml-1":n.event.details||n.event.additionalDetails}])},{default:g(()=>r[0]||(r[0]=[y("→")])),_:1},8,["class"])):v("",!0),n.event.additionalDetails?(o(),c(a,{key:3,class:"cursor-text rounded bg-neutral-200 px-0.5 font-mono text-black dark:bg-gray-400 dark:text-white"},{default:g(()=>[y(C(n.event.additionalDetails),1)]),_:1})):v("",!0)])}}}),we={class:"px-2"},xe=f({__name:"HistoryEvent",props:{event:{}},setup(e){const{getEventOutput:t}=Z(),n=t(e.event);return(r,a)=>(o(),u("div",we,[k(n).component?(o(),c(oe(k(n).component),{key:0,event:k(n)},null,8,["event"])):(o(),c(Ie,{key:1,event:k(n)},null,8,["event"]))]))}}),He={class:"flex border-neutral-100 bg-blue-50 dark:border-gray-900 dark:bg-gray-500"},Ee={class:"flex-initial rounded-t-lg border border-b-0 border-neutral-100 bg-blue-200 dark:border-gray-700 dark:bg-gray-700"},Se=f({__name:"HistoryEventHeader",props:{createdAt:{}},setup(e){return(t,n)=>{const r=T("CommonDateTime"),a=T("CommonLabel");return o(),u("div",He,[R("div",Ee,[b(a,{class:"m-1 rounded p-1 text-black dark:text-white","prefix-icon":"calendar-date-time",size:"medium"},{default:g(()=>[b(r,{"date-time":t.createdAt,type:"absolute","absolute-format":"datetime"},null,8,["date-time"])]),_:1})])])}}}),je=f({__name:"HistoryEventIssuer",props:{issuer:{}},setup(e){const{issuedBySystemService:t,issuedBySystemUser:n,getIssuerName:r}=Z();return(a,i)=>{const d=T("CommonIcon"),m=T("CommonLabel");return o(),c(m,{class:"p-2"},{default:g(()=>[k(t)(a.issuer)?(o(),c(d,{key:0,class:"text-yellow-700 dark:text-yellow-300",name:"play-circle",size:"small"})):k(n)(a.issuer)?k(n)(a.issuer)?(o(),c(re,{key:2,icon:"logo",class:"dark:bg-white",size:"xs"})):v("",!0):(o(),c(ae,{key:1,entity:a.issuer,size:"xs","no-indicator":""},null,8,["entity"])),y(" "+C(k(r)(a.issuer)),1)]),_:1})}}}),Oe={ref:"history-container"},dt=f({__name:"TicketHistoryFlyout",props:{ticket:{}},setup(e){const t=new W(me({ticketId:e.ticket.id})),n=t.result(),r=t.loading(),a=S(()=>{var m;return(m=n.value)==null?void 0:m.ticketHistory}),i=S(()=>a.value!==void 0?!1:r.value),d=ie("history-container");return F([d,r],m=>{var N;!m||!((N=n.value)!=null&&N.ticketHistory.length)||se(()=>{var h;(h=d.value)==null||h.scrollIntoView({behavior:"instant",block:"end"})})},{flush:"post"}),F(()=>e.ticket,()=>t.refetch()),(m,N)=>{const h=ce("tooltip");return o(),c(ee,{"header-title":m.__("Ticket History"),"header-icon":"clock-history",size:"large",name:"ticket-history","no-close-on-action":"","hide-footer":""},{default:g(()=>[b(X,{loading:i.value,"no-transition":""},{default:g(()=>[R("div",Oe,[(o(!0),u(x,null,H(a.value,(l,p)=>(o(),u("div",{key:`${l.createdAt}-${p}`,class:I(["my-3",{"mt-0":p===0}])},[b(Se,{"created-at":l.createdAt},null,8,["created-at"]),(o(!0),u(x,null,H(l.records,(s,$)=>(o(),u("div",{key:`${"id"in s.issuer?s.issuer.id:s.issuer.klass}-${$}`,class:I([{"rounded-b-none":$!==l.records.length-1,"rounded-tr-none":$===l.records.length-1&&l.records.length>1,"border-b-0":$!==l.records.length-1,"border-t-0":$===l.records.length-1&&l.records.length>1},"rounded-lg rounded-tl-none border border-neutral-100 bg-blue-200 pb-1 dark:border-gray-700 dark:bg-gray-700"])},[b(je,{issuer:s.issuer},null,8,["issuer"]),(o(!0),u(x,null,H(s.events,(w,G)=>le((o(),c(xe,{key:`${w.createdAt}-${G}`,event:w},null,8,["event"])),[[h,k(_).dateTimeISO(w.createdAt)]])),128)),$!==l.records.length-1?(o(),c(Y,{key:0,class:"mt-2 px-2","alternative-background":""})):v("",!0)],2))),128))],2))),128))],512)]),_:1},8,["loading"])]),_:1},8,["header-title"])}}});export{dt as default};
//# sourceMappingURL=TicketHistoryFlyout-BhLoj9zT.js.map
