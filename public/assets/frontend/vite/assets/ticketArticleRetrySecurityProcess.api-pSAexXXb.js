import{n as k,c as A,r as v,k as D}from"./vue-oicRkvo0.js";import{n as y}from"./vendor-C11O1Xx8.js";import{u as H,Q as N,f as R,e as M,M as x,N as b,c as P}from"./apollo-Cj5TVUDk.js";import{n as _}from"./lodash-pFOI14f-.js";import{g as F}from"./index-D5f5eTVX.js";import{w as O}from"./dom-0wVl69Vp.js";import{b4 as j,X as T}from"./overviewAttributes.api-C09LSZ8O.js";const ne=(t,i)=>({openReplyForm:async(e={})=>{var u,s;const a=(u=t.value)==null?void 0:u.formNode;await i();const{articleType:c,...d}=e,f=a.find("articleType","name");a.context&&Object.assign(a.context,{_open:!0}),f==null||f.input(c,!1),await k();for(const[l,o]of Object.entries(d)){const g=a.find(l,"name");if(g==null||g.input(o,!1),g&&(l==="to"||l==="cc")){const p=Array.isArray(o)?o.map(I=>({value:I,label:I})):[{value:o,label:o}];g.emit("prop:options",p)}}a.emit("article-reply-open",c);const m=(s=a.find("body","name"))==null?void 0:s.context;m==null||m.focus(),k(()=>{a.context&&Object.assign(a.context,{_open:!1})})},getNewArticleBody:e=>{var d,f;const a=(d=t.value)==null?void 0:d.getNodeByName("body");if(!a)return"";const c=(f=a.context)==null?void 0:f.getEditorValue;return typeof c=="function"?c(e):""}}),E=y`
    fragment ticketArticleAttributes on TicketArticle {
  id
  internalId
  from {
    raw
    parsed {
      name
      emailAddress
      isSystemAddress
    }
  }
  messageId
  to {
    raw
    parsed {
      name
      emailAddress
      isSystemAddress
    }
  }
  cc {
    raw
    parsed {
      name
      emailAddress
      isSystemAddress
    }
  }
  subject
  replyTo {
    raw
    parsed {
      name
      emailAddress
      isSystemAddress
    }
  }
  messageId
  messageIdMd5
  inReplyTo
  contentType
  attachmentsWithoutInline {
    id
    internalId
    name
    size
    type
    preferences
  }
  preferences
  bodyWithUrls
  internal
  createdAt
  author {
    id
    fullname
    firstname
    lastname
    email
    active
    image
    vip
    outOfOffice
    outOfOfficeStartAt
    outOfOfficeEndAt
    authorizations {
      provider
      uid
      username
    }
  }
  type {
    name
    communication
  }
  sender {
    name
  }
  securityState {
    encryptionMessage
    encryptionSuccess
    signingMessage
    signingSuccess
    type
  }
  mediaErrorState {
    error
  }
  detectedLanguage
}
    `,L=y`
    query ticketArticles($ticketId: ID, $ticketInternalId: Int, $ticketNumber: String, $beforeCursor: String, $afterCursor: String, $pageSize: Int, $loadFirstArticles: Boolean = true, $firstArticlesCount: Int = 1) {
  firstArticles: ticketArticles(
    ticket: {ticketId: $ticketId, ticketInternalId: $ticketInternalId, ticketNumber: $ticketNumber}
    first: $firstArticlesCount
  ) @include(if: $loadFirstArticles) {
    edges {
      node {
        ...ticketArticleAttributes
      }
    }
  }
  articles: ticketArticles(
    ticket: {ticketId: $ticketId, ticketInternalId: $ticketInternalId, ticketNumber: $ticketNumber}
    before: $beforeCursor
    after: $afterCursor
    last: $pageSize
  ) {
    totalCount
    edges {
      node {
        ...ticketArticleAttributes
      }
      cursor
    }
    pageInfo {
      endCursor
      startCursor
      hasPreviousPage
    }
  }
}
    ${E}`;function Q(t={},i={}){return H(L,t,i)}const z=y`
    subscription ticketArticleUpdates($ticketId: ID!) {
  ticketArticleUpdates(ticketId: $ticketId) {
    addArticle {
      id
      createdAt
    }
    updateArticle {
      ...ticketArticleAttributes
    }
    removeArticleId
  }
}
    ${E}`,ie=(t,i={pageSize:20})=>{const r=A(()=>{var s;return((s=i.firstArticlesCount)==null?void 0:s.value)||5}),n=new N(Q(()=>({ticketId:t.value,pageSize:i.pageSize||20,firstArticlesCount:r.value}),{context:{batch:{active:!1}}})),e=n.result(),a=A(()=>e.value),c=A(()=>{var s,l,o;return(s=e.value)!=null&&s.articles.totalCount?((l=e.value)==null?void 0:l.articles.edges.length)<((o=e.value)==null?void 0:o.articles.totalCount):!1}),d=s=>{n.refetch({ticketId:t.value,pageSize:s})},f=n.loading(),m=A(()=>a.value!==void 0?!1:f.value),u=s=>{const l={};return s?l.endCursor=s:(l.startCursor=null,l.endCursor=null),l};return n.subscribeToMore(()=>({document:z,variables:{ticketId:t.value},onError:_,updateQuery(s,{subscriptionData:l}){var I;const o=l.data.ticketArticleUpdates;if(!s.articles||o.updateArticle)return s;const g=s.articles.edges,p=g.length;if(o.removeArticleId){const S=g.filter(h=>h.node.id!==o.removeArticleId),w=S.length!==p;if(w&&!c.value)return d(r.value),s;const C={...s,articles:{...s.articles,edges:S,totalCount:s.articles.totalCount-1}};if(w){const h=g[p-2];C.articles.pageInfo={...s.articles.pageInfo,...u(h.cursor)}}return k(()=>{R().cache.gc()}),C}return o.addArticle&&((I=i==null?void 0:i.onAddArticleCallback)==null||I.call(i,{updates:o,previousArticlesEdges:g,previousArticlesEdgesCount:p,articlesQuery:n,result:e,allArticleLoaded:c,refetchArticlesQuery:d})),s}})),{articlesQuery:n,articleResult:e,articleData:a,allArticleLoaded:c,isLoadingArticles:m,refetchArticlesQuery:d}},se=t=>{const i=A(()=>{var e;return F((e=t.value)==null?void 0:e.initialChannel)}),r=A(()=>{var e;return t.value?(e=i.value)==null?void 0:e.channelAlert(t.value):null}),n=A(()=>{var e;return!!r.value&&!!((e=r.value)!=null&&e.text)});return{channelPlugin:i,channelAlert:r,hasChannelAlert:n}},B=()=>{let t="",i="",r=null;if(window.getSelection?(r=window.getSelection(),t=(r==null?void 0:r.toString())||""):document.getSelection&&(r=document.getSelection(),t=(r==null?void 0:r.toString())||""),r&&r.rangeCount){const n=document.createElement("div");for(let e=1;e<=r.rangeCount;e+=1)n.appendChild(r.getRangeAt(e-1).cloneContents());i=n.innerHTML}return{text:t.toString().trim()||"",html:i,selection:r}},G=(t,i)=>{for(;t.parentNode;){if("matches"in t&&t.matches(i))return t;t=t.parentNode}return null},$=(t,i)=>!!G(t,`#article-${i} .Content`),q=(t,i)=>!!t.containsNode(i,!1),ae=t=>{const i=window.getSelection();if(!i||i.rangeCount<=0)return;const r=i.getRangeAt(0),n=document.querySelector(`#article-${t} .Content`);if(!n)return;const e=$(r.startContainer,t),a=$(r.endContainer,t),c=q(i,n);if(e||a||c)return!e&&a?r.setStart(n,0):e&&!a?r.setEnd(n,n.childNodes.length):c&&(r.setStart(n,0),r.setEnd(n,n.childNodes.length)),B()},ce=()=>{let r=0,n=0;const e=v(),a=v(!0),c=v(!1),d=u=>{const s=u.querySelector(".js-signatureMarker");return s||u.querySelector("div [data-signature=true]")},f=async()=>{if(!e.value)return;const u=e.value.style;if(u.height="",await j(),!e.value)return;const s=e.value.clientHeight;r=s;const l=d(e.value),o=(l==null?void 0:l.offsetTop)||0;o>0&&o<320?(n=o<60?60:o,a.value=!0):s>320?(n=320,a.value=!0):(a.value=!1,n=0),n&&(u.height=`${n}px`)};return D(async()=>{e.value&&(await O(e),await f())}),{toggleShowMore:()=>{var l;if(!e.value)return;c.value=!c.value;const u=e.value.style;u.transition="height 0.3s ease-in-out",u.height=c.value?`${r+10}px`:`${n}px`;const s=()=>{var o;u.transition="",(o=e.value)==null||o.removeEventListener("transitionend",s)};(l=e.value)==null||l.addEventListener("transitionend",s)},hasShowMore:a,shownMore:c,bubbleElement:e}},oe=(t,i)=>({populateInlineImages:n=>{t.value.splice(0),n.querySelectorAll("img").forEach(e=>{var f;const a=(f=e.alt||e.src)!=null&&f.match(/\.(jpe?g)$/i)?"image/jpeg":"image/png",c={name:e.alt,inline:e.src,type:a};e.classList.add("cursor-pointer");const d=t.value.push(c)-1;e.onclick=m=>{m.preventDefault(),m.stopPropagation(),i(d)}})}}),U=y`
    mutation ticketArticleRetryMediaDownload($articleId: ID!) {
  ticketArticleRetryMediaDownload(articleId: $articleId) {
    success
    errors {
      ...errors
    }
  }
}
    ${T}`;function X(t={}){return M(U,t)}const le=t=>{const i=new x(X(()=>({variables:{articleId:t.value}}))),{notify:r}=P(),n=v(!1);return{loading:n,tryAgain:async()=>{var a;n.value=!0;try{const c=await i.send();if(!((a=c==null?void 0:c.ticketArticleRetryMediaDownload)!=null&&a.success))throw new Error;return r({id:"media-download-success",type:b.Success,message:__("Media download was successful.")}),Promise.resolve()}catch(c){return r({id:"media-download-failed",type:b.Error,message:__("Media download failed. Please try again later.")}),Promise.reject(c)}finally{n.value=!1}}}},V=y`
    fragment securityState on TicketArticleSecurityState {
  type
  signingSuccess
  signingMessage
  encryptionSuccess
  encryptionMessage
}
    `,W=y`
    mutation ticketArticleRetrySecurityProcess($articleId: ID!) {
  ticketArticleRetrySecurityProcess(articleId: $articleId) {
    retryResult {
      ...securityState
    }
    article {
      id
      securityState {
        ...securityState
      }
    }
    errors {
      ...errors
    }
  }
}
    ${V}
${T}`;function ue(t={}){return M(W,t)}export{ne as a,ce as b,oe as c,le as d,ie as e,ue as f,ae as g,se as u};
//# sourceMappingURL=ticketArticleRetrySecurityProcess.api-pSAexXXb.js.map
