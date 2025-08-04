import{p as K}from"./utils-C-eON4SW.js";import{X as z,at as G,aA as X,aX as Y,az as S,aH as F}from"./overviewAttributes.api-C09LSZ8O.js";import{u as J}from"./useObjectAttributeFormData-BTXeBYyl.js";import{n as O}from"./vendor-C11O1Xx8.js";import{T as Q}from"./ticketAttributes.api-rqx5ITab.js";import{e as W,M as Z,a as ee,S as te}from"./apollo-Cj5TVUDk.js";import{q as j,e as ie,a as ne}from"./routes-CgLO9M4y.js";import{b as ae,k as re}from"./lodash-pFOI14f-.js";import{r as D,c as l,w as se,s as oe}from"./vue-oicRkvo0.js";import{u as le}from"./useTicketView-CMOCBKg-.js";import{a as ue}from"./index-D5f5eTVX.js";const ce=O`
    mutation ticketUpdate($ticketId: ID!, $input: TicketUpdateInput!, $meta: TicketUpdateMetaInput!) {
  ticketUpdate(ticketId: $ticketId, input: $input, meta: $meta) {
    ticket {
      ...ticketAttributes
    }
    errors {
      ...errors
    }
  }
}
    ${Q}
${z}`;function pe(n={}){return W(ce,n)}const de=["id","group","owner","state","pending_time","priority","customer","organization","objectAttributeValues"],we=(n,m,A)=>{const v=D(),b=new Z(pe(),{errorCallback:A,errorNotificationMessage:__("Ticket update failed.")}),o=l(t=>{if(!n.value)return{};const e=de.reduce((r,u)=>(!n.value||!(u in n.value)||(r[u]=n.value[u]),r),{});return t&&ae(e,t)?t:e});se(o,()=>{var e,r;if(!n.value)return;const{internalId:t}=n.value.owner;v.value={id:n.value.id,owner_id:t===1?null:t,isDefaultFollowUpStateSet:void 0},(e=m.value)!=null&&e.formInitialSettled&&((r=m.value)==null||r.resetForm({values:v.value,object:n.value},{resetDirty:!1}))},{immediate:!0});const h=l(()=>{var e,r,u;const t=(r=(e=m.value)==null?void 0:e.formNode)==null?void 0:r.at("ticket");return!!((u=t==null?void 0:t.context)!=null&&u.state.valid)}),{attributesLookup:g}=G(j.Ticket),T=(t,e)=>{var u,f;if(!e)return null;const r=((f=(u=X(t,"body"))==null?void 0:u.context)==null?void 0:f.contentType)||"text/html";return r==="text/html"&&(e.body=K(e.body)),{type:e.articleType,body:e.body,internal:e.internal,cc:e.cc,to:e.to,subject:e.subject,subtype:e.subtype,inReplyTo:e.inReplyTo,contentType:r,attachments:Y(t,e.attachments),security:e.security,timeUnit:e.timeUnit,accountedTimeTypeId:e.accountedTimeTypeId}};return{initialTicketValue:v,isTicketFormGroupValid:h,editTicket:async(t,e)=>{if(!n.value||!m.value)return;t.owner_id||(t.owner_id=1);const{internalObjectAttributeValues:r,additionalObjectAttributeValues:u}=J(g.value,t),f=t.article,w=T(m.value.formId,f),$=e||{};return b.send({ticketId:n.value.id,input:{...r,objectAttributeValues:u,article:w},meta:$})}}},$e=(n,m)=>{const A=F(),v=l(()=>n.value?ue(n.value,A):[]),b=l(()=>re(v.value,"value")),o=oe(),h=l(()=>{var i,s;return(s=(i=o.value)==null?void 0:i.options)==null?void 0:s.recipientContact}),g=l(()=>{var i;return(i=o.value)==null?void 0:i.contentType}),T=l(()=>{var i;return{mentionText:{groupNodeName:"group_id"},mentionUser:{groupNodeName:"group_id"},mentionKnowledgeBase:{attachmentsNodeName:"attachments"},...(i=o.value)==null?void 0:i.editorMeta}}),t=["to","cc","subject","body","attachments","security"].reduce((i,s)=>(i[s]={validation:l(()=>{var a,p,c;return((c=(p=(a=o.value)==null?void 0:a.fields)==null?void 0:p[s])==null?void 0:c.validation)||null}),required:l(()=>{var a,p,c;return!!((c=(p=(a=o.value)==null?void 0:a.fields)==null?void 0:p[s])!=null&&c.required)})},i),{}),{isTicketAgent:e,isTicketCustomer:r,isTicketEditable:u}=le(n),f=A==="mobile",w={type:"group",name:"ticket",isGroupOrList:!0,children:[...f?[{name:"title",type:"text",label:__("Ticket title"),required:!0}]:[],{type:"hidden",name:"isDefaultFollowUpStateSet"},{screen:"edit",object:j.Ticket}]},$={if:f?"$newTicketArticleRequested || $newTicketArticlePresent":void 0,type:"group",name:"article",isGroupOrList:!0,children:[{type:"hidden",name:"inReplyTo"},{if:"$currentArticleType.fields.subtype",type:"hidden",name:"subtype"},{name:"articleType",label:__("Channel"),labelSrOnly:f,type:"select",hidden:l(()=>v.value.length===1),props:{noInitialAutoPreselect:!0,options:v}},{name:"internal",label:__("Visibility"),labelSrOnly:f,hidden:r,type:"select",props:{options:[{value:!0,label:__("Internal"),icon:"lock"},{value:!1,label:__("Public"),icon:"unlock"}]}},{if:"$currentArticleType.fields.to",name:"to",label:__("To"),type:"recipient",validation:t.to.validation,props:{contact:h,multiple:!0},required:t.to.required},{if:"$currentArticleType.fields.cc",name:"cc",label:__("CC"),type:"recipient",validation:t.cc.validation,props:{contact:h,multiple:!0}},{if:"$currentArticleType.fields.subject",name:"subject",label:__("Subject"),type:"text",validation:t.subject.validation,props:{maxlength:200},required:t.subject.required},{if:"$securityIntegration === true && $currentArticleType.fields.security",name:"security",label:__("Security"),type:"security",validation:t.security.validation},{name:"body",screen:"edit",object:j.TicketArticle,validation:t.body.validation,props:{ticketId:l(()=>{var i;return(i=n.value)==null?void 0:i.internalId}),customerId:l(()=>{var i;return(i=n.value)==null?void 0:i.customer.internalId}),contentType:g,meta:T},required:t.body.required},{if:"$currentArticleType.fields.attachments",type:"file",name:"attachments",label:__("Attachment"),labelSrOnly:!0,validation:t.attachments.validation,props:{multiple:l(()=>{var i,s,a,p,c,y;return!!(typeof((a=(s=(i=o.value)==null?void 0:i.fields)==null?void 0:s.attachments)==null?void 0:a.multiple)!="boolean"||(y=(c=(p=o.value)==null?void 0:p.fields)==null?void 0:c.attachments)!=null&&y.multiple)}),allowedFiles:l(()=>{var i,s,a;return((a=(s=(i=o.value)==null?void 0:i.fields)==null?void 0:s.attachments)==null?void 0:a.allowedFiles)||null}),accept:l(()=>{var i,s,a;return((a=(s=(i=o.value)==null?void 0:i.fields)==null?void 0:s.attachments)==null?void 0:a.accept)||null})},required:t.attachments.required}]},H=()=>{const i=(a,p,c)=>p.fields.articleType?!(a===S.FieldChange&&(!c||c.name!=="articleType")):!1,s=(a,p,c)=>{var E,U,N,V,M,C;const{formNode:y,changedField:d,formUpdaterData:I}=c,{schemaData:B}=p;if(a===S.Initial&&((E=I==null?void 0:I.fields.articleType)!=null&&E.value)&&(o.value=b.value[I.fields.articleType.value]),!i(a,B,d)||!n.value||!y)return;const L=y.find("body","name"),q={body:L==null?void 0:L.context};if((d==null?void 0:d.newValue)!==(d==null?void 0:d.oldValue)&&((N=(U=o.value)==null?void 0:U.onDeselected)==null||N.call(U,n.value,q)),!(d!=null&&d.newValue))return;const _=b.value[d==null?void 0:d.newValue];_&&((V=y.context)!=null&&V._open||(M=_.onSelected)==null||M.call(_,n.value,q,m.value),o.value=_,(C=y.find("internal"))==null||C.input(_.internal,!1))};return{execution:[S.Initial,S.FieldChange],callback:s}},R=i=>{i.on("article-reply-open",({payload:s})=>{var y;if(!s||!n.value)return;const a=b.value[s];if(!a)return;const c={body:i.find("body","name").context};(y=a.onOpened)==null||y.call(a,n.value,c,m.value)})},x=ie(),P=l(()=>(x.config.smime_integration||x.config.pgp_integration)??!1);return{ticketSchema:w,articleSchema:$,currentArticleType:o,ticketArticleTypes:v,securityIntegration:P,isTicketAgent:e,isTicketCustomer:r,isTicketEditable:u,articleTypeHandler:H,articleTypeSelectHandler:R}},me=O`
    fragment ticketLiveUserAttributes on TicketLiveUser {
  user {
    id
    firstname
    lastname
    fullname
    email
    vip
    outOfOffice
    outOfOfficeStartAt
    outOfOfficeEndAt
    active
    image
  }
  apps {
    name
    editing
    lastInteraction
  }
}
    `,ve=O`
    subscription ticketLiveUserUpdates($key: String!, $app: EnumTaskbarApp!) {
  ticketLiveUserUpdates(key: $key, app: $app) {
    liveUsers {
      ...ticketLiveUserAttributes
    }
  }
}
    ${me}`;function ye(n,m={}){return ee(ve,n,m)}const Le=(n,m,A)=>{const v=D([]),{userId:b}=ne(),o=F(),h=T=>{const k=[];return T.forEach(t=>{let e=t.apps.filter(r=>r.editing);t.user.id===b&&(e.length===0||(e=e.filter(r=>r.name!==o),e.length===0))||(e.length===0&&(e=t.apps),e.sort((r,u)=>new Date(u.lastInteraction).getTime()-new Date(r.lastInteraction).getTime()),k.push({user:t.user,...e[0],app:e[0].name}))}),k};return new te(ye(()=>({key:`Ticket-${n.value}`,app:A}),()=>({fetchPolicy:"no-cache",enabled:m.value}))).onResult(T=>{var k;v.value=h(((k=T.data)==null?void 0:k.ticketLiveUserUpdates.liveUsers)||[])}),{liveUserList:v}};export{$e as a,Le as b,we as c,pe as u};
//# sourceMappingURL=useTicketLiveUserList-fkbxnu3k.js.map
