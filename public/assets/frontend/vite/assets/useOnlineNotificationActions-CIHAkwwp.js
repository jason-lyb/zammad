import{u as x}from"./getUserDisplayName-Dg0PCZQh.js";import{u as A,e as w,M as y,f as C}from"./apollo-Cj5TVUDk.js";import{i as o}from"./routes-CgLO9M4y.js";import{aI as M,aJ as O,X as I}from"./overviewAttributes.api-C09LSZ8O.js";import{l as v,n as b}from"./vendor-C11O1Xx8.js";import{c as D}from"./vue-oicRkvo0.js";import{u as Q}from"./seen.api-DLK-LLmy.js";import{a as T}from"./lodash-pFOI14f-.js";const j=e=>"#",S=(e,t,i)=>{if(!i)return o.t("You can no longer see the data privacy task.");const n=i.deletableId||"-";switch(e){case"create":return o.t("%s created data privacy task to delete user ID |%s|",t,n);case"update":return o.t("%s updated data privacy task to delete user ID |%s|",t,n);case"completed":return o.t("%s completed data privacy task to delete user ID |%s|",t,n);default:return null}},q={messageText:S,path:j,model:"DataPrivacyTask"},Y=e=>"#",z=(e,t,i)=>{if(!i)return o.t("You can no longer see the group.");const n=i.name||"-";switch(e){case"create":return o.t("%s created group |%s|",t,n);case"update":return o.t("%s updated group |%s|",t,n);default:return null}},E={messageText:z,path:Y,model:"Group"},U=e=>`organizations/${e.internalId}`,B=(e,t,i)=>{if(!i)return o.t("You can no longer see the organization.");const n=i.name||"-";switch(e){case"create":return o.t("%s created organization |%s|",t,n);case"update":return o.t("%s updated organization |%s|",t,n);default:return null}},P={path:U,messageText:B,model:"Organization"},R=e=>"#",W=(e,t,i)=>{if(!i)return o.t("You can no longer see the role.");const n=i.name||"-";switch(e){case"create":return o.t("%s created role |%s|",t,n);case"update":return o.t("%s updated role |%s|",t,n);default:return null}},F={messageText:W,path:R,model:"Role"},G=e=>`tickets/${e.ticket.internalId}#article-${e.internalId}`,H=(e,t,i)=>{var c,l,m,h,_,f,k;if(!i)return o.t("You can no longer see the ticket.");const n=((c=i.ticket)==null?void 0:c.title)||"-";switch(e){case"create":return o.t("%s created article for |%s|",t,n);case"update":return o.t("%s updated article for |%s|",t,n);case"update.reaction":return o.t("%s reacted with a %s to message from %s |%s|",((h=(m=(l=i.preferences)==null?void 0:l.whatsapp)==null?void 0:m.reaction)==null?void 0:h.author)||"-",((k=(f=(_=i.preferences)==null?void 0:_.whatsapp)==null?void 0:f.reaction)==null?void 0:k.emoji)||"-",t,M(O(i.bodyWithUrls))||"-");default:return null}},J={messageText:H,path:G,model:"Ticket::Article"},X=e=>`tickets/${e.internalId}`,K=(e,t,i)=>{if(!i)return o.t("You can no longer see the ticket.");const n=i.title||"-";switch(e){case"create":return o.t("%s created ticket |%s|",t,n);case"update":return o.t("%s updated ticket |%s|",t,n);case"reminder_reached":return o.t("Pending reminder reached for ticket |%s|",n);case"escalation":return o.t("Ticket |%s| has escalated!",n);case"escalation_warning":return o.t("Ticket |%s| will escalate soon!",n);case"update.merged_into":return o.t("Ticket |%s| was merged into another ticket",n);case"update.received_merge":return o.t("Another ticket was merged into ticket |%s|",n);default:return null}},L={path:X,messageText:K,model:"Ticket"},V=e=>`users/${e.internalId}`,Z=(e,t,i)=>{if(!i)return o.t("You can no longer see the user.");const n=i.fullname||"-";switch(e){case"create":return o.t("%s created user |%s|",t,n);case"update":return o.t("%s updated user |%s|",t,n);case"session started":return o.t("%s started a new session",t);case"switch to":return o.t("%s switched to |%s|!",t,n);case"ended switch to":return o.t("%s ended switch to |%s|!",t,n);default:return null}},ee={messageText:Z,path:V,model:"User"},te=Object.assign({"./builders/data-privacy-task.ts":q,"./builders/group.ts":E,"./builders/organization.ts":P,"./builders/role.ts":F,"./builders/ticket-article.ts":J,"./builders/ticket.ts":L,"./builders/user.ts":ee}),ne=Object.values(te).reduce((e,t)=>(e[t.model]=t,e),{}),me=e=>{var c,l;const t=D(()=>ne[e.value.objectName]);t.value||v.error(`Object missing ${e.value.objectName}.`);const i=(c=t.value)==null?void 0:c.messageText(e.value.typeName,e.value.createdBy?x(e.value.createdBy):"",e.value.metaObject),n=e.value.metaObject?(l=t.value)==null?void 0:l.path(e.value.metaObject):void 0;return t.value&&!i&&v.error(`Unknown action for (${e.value.objectName}/${e.value.typeName}), extend activityMessages() of model.`),{link:n,builder:t,message:i}},$=b`
    query onlineNotifications {
  onlineNotifications {
    edges {
      node {
        id
        seen
        createdAt
        createdBy {
          id
          fullname
          lastname
          firstname
          email
          vip
          outOfOffice
          outOfOfficeStartAt
          outOfOfficeEndAt
          active
          image
        }
        typeName
        objectName
        metaObject {
          ... on Ticket {
            id
            internalId
            title
          }
          ... on TicketArticle {
            id
            internalId
            ticket {
              id
              internalId
              title
            }
            to {
              raw
            }
            bodyWithUrls
            preferences
          }
        }
      }
      cursor
    }
    pageInfo {
      endCursor
      hasNextPage
    }
  }
}
    `;function he(e={}){return A($,{},e)}const oe=b`
    mutation onlineNotificationDelete($onlineNotificationId: ID!) {
  onlineNotificationDelete(onlineNotificationId: $onlineNotificationId) {
    success
    errors {
      ...errors
    }
  }
}
    ${I}`;function ie(e={}){return w(oe,e)}const se=b`
    mutation onlineNotificationMarkAllAsSeen($onlineNotificationIds: [ID!]!) {
  onlineNotificationMarkAllAsSeen(onlineNotificationIds: $onlineNotificationIds) {
    onlineNotifications {
      id
      seen
    }
    errors {
      ...errors
    }
  }
}
    ${I}`;function ae(e={}){return w(se,e)}const _e=()=>{const{cache:e}=C(),t=()=>{const a={query:$},s=e.readQuery(a);if(!(s!=null&&s.onlineNotifications))return null;const r=T(s);return{queryOptions:a,oldQueryCache:r,existingQueryCache:s}},i=a=>{const s=t();if(!s)return;const{queryOptions:r,oldQueryCache:p,existingQueryCache:d}=s;return e.writeQuery({...r,data:{onlineNotifications:{edges:d.onlineNotifications.edges.filter(u=>u.node.id!==a),pageInfo:d.onlineNotifications.pageInfo}}}),()=>{e.writeQuery({...r,data:p})}},n=a=>{const s=t();if(!s)return;const{queryOptions:r,oldQueryCache:p,existingQueryCache:d}=s,u=T(d);return a.forEach(N=>u.onlineNotifications.edges.forEach(({node:g})=>{g.id===N&&(g.seen=!0)})),e.writeQuery({...r,data:{onlineNotifications:{...u.onlineNotifications}}}),()=>{e.writeQuery({...r,data:p})}},c=a=>{const s=t();if(!s)return;const{queryOptions:r,oldQueryCache:p,existingQueryCache:d}=s,u=T(d);return u.onlineNotifications.edges.forEach(({node:N})=>{var g;((g=N.metaObject)==null?void 0:g.id)===a&&(N.seen=!0)}),e.writeQuery({...r,data:{onlineNotifications:{...u.onlineNotifications}}}),()=>{e.writeQuery({...r,data:p})}},l=new y(Q(),{errorNotificationMessage:__("The online notification could not be marked as seen.")}),m=async a=>{const s=c(a);return l.send({objectId:a}).catch(()=>s)},h=new y(ae(),{errorNotificationMessage:__("Cannot set online notifications as seen")}),_=a=>{const s=n(a);return h.send({onlineNotificationIds:a}).catch(()=>s)},f=new y(ie());return{seenNotification:m,deleteNotification:async a=>{const s=i(a);return f.send({onlineNotificationId:a}).catch(()=>s)},deleteNotificationMutation:f,markAllRead:_}};export{me as a,_e as b,he as u};
//# sourceMappingURL=useOnlineNotificationActions-CIHAkwwp.js.map
