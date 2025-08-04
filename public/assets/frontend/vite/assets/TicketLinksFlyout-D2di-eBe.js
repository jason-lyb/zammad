import{e as N,M as A,N as F,c as M}from"./apollo-Cj5TVUDk.js";import{_ as q}from"./Form.vue_vue_type_script_setup_true_lang-B6L-6HzY.js";import{u as B}from"./useForm-CUKec4n5.js";import{a5 as $}from"./routes-CgLO9M4y.js";import{_ as O}from"./CommonFlyout.vue_vue_type_script_setup_true_lang-Cr1ukr3s.js";import{c as S}from"./useFlyout-KZXqW5RR.js";import{u as V,_ as j}from"./useTargetTicketOptions-Dw9uFPEv.js";import{n as D,L as d}from"./CommonDropdown.vue_vue_type_script_setup_true_lang-DOCvnZ_a.js";import{n as P}from"./vendor-C11O1Xx8.js";import{f as Q,t as x,c as z,m as E,D as H,y as K,I as R,q as k,u as f}from"./vue-oicRkvo0.js";import"./lodash-pFOI14f-.js";import"./formkit-5nol1GBe.js";import"./overviewAttributes.api-C09LSZ8O.js";import"./vite-FJshFMF2.js";import"./FormGroup.vue_vue_type_script_setup_true_lang-DIx-HUKU.js";import"./desktop-l0eJ1dZN.js";import"./useCopyToClipboard-CjkPg__g.js";import"./theme-Bv2ClBzZ.js";import"./datepicker-BBNcWeHz.js";import"./date-B2UyDZN7.js";import"./autocompleteTags.api-CG5-cm_A.js";import"./autocompleteSearchTicket.api-DfOQWGlO.js";import"./ticketUpdates.api-BhGIG_Ti.js";import"./ticketAttributes.api-rqx5ITab.js";import"./useTicketCreateArticleType-D7iVcJ_6.js";import"./types-Cu-Nkl7K.js";import"./useTicketCreateView-HCH46SPv.js";import"./commonjsHelpers-BosuxZz1.js";import"./CommonOverlayContainer.vue_vue_type_script_setup_true_lang-CxyKmNUC.js";import"./LayoutSidebar.vue_vue_type_script_setup_true_lang-BO1pkKrb.js";import"./getTicketNumber-CTSsSeKd.js";import"./CommonError.vue_vue_type_script_setup_true_lang-B76hdJ4v.js";import"./LayoutMain.vue_vue_type_script_setup_true_lang-DIWzj6-0.js";import"./index-DwuY2HL4.js";import"./CommonInlineEdit.vue_vue_type_script_setup_true_lang-Blo3VlqB.js";import"./useHtmlLinks-53b5zJaG.js";import"./pwa-THoW_3xc.js";import"./useBaseUrl-BsZiEKQE.js";import"./useUserDetail-C29_PwWz.js";import"./user.api-BwewaCks.js";import"./ObjectAttributes.vue_vue_type_script_setup_true_lang-B0DrxGTz.js";import"./useDisplayObjectAttributes-sspS-pHp.js";import"./useTicketView-CMOCBKg-.js";import"./CommonSectionCollapse.vue_vue_type_script_setup_true_lang-B-hHJAEI.js";import"./NavigationMenuList.vue_vue_type_script_setup_true_lang-CYOBePFr.js";import"./useTicketAccountedTime-CSL2Xls9.js";import"./useTicketSubscribe-CmWzZx1x.js";import"./useOrganizationDetail-CenI9U-0.js";import"./dom-0wVl69Vp.js";import"./useAttachments-0IU6Vvzp.js";import"./getAttachmentLinks-Dz1qdLDp.js";const G=P`
    mutation linkAdd($input: LinkInput!) {
  linkAdd(input: $input) {
    link {
      type
      item {
        ... on Ticket {
          id
          internalId
          title
          state {
            id
            name
          }
          stateColorCode
        }
        ... on KnowledgeBaseAnswerTranslation {
          id
        }
      }
    }
    errors {
      message
      field
    }
  }
}
    `;function J(n={}){return N(G,n)}const U={class:"space-y-6"},Ut=Q({__name:"TicketLinksFlyout",props:{sourceTicket:{}},setup(n){const i=x(n,"sourceTicket"),{form:m,updateFieldValues:y,onChangedField:T}=B(),{formListTargetTicketOptions:_,targetTicketId:L,handleTicketClick:I}=V(T,y),{linkTypes:g}=D(),v=[{isLayout:!0,element:"div",attrs:{class:"grid gap-y-2.5 gap-x-3"},children:[{name:"targetTicketId",type:"ticket",label:__("Link ticket"),exceptTicketInternalId:i.value.internalId,options:_,clearable:!0,required:!0},{name:"linkType",type:"select",label:__("Link type"),options:g}]}],b={linkType:$.Normal},h=z(()=>({actionButton:{variant:"submit",type:"submit"},actionLabel:__("Link"),form:m.value})),{notify:w}=M(),C=async o=>new A(J({variables:{input:{sourceId:o.targetTicketId,targetId:i.value.id,type:o.linkType}},update:(e,{data:p})=>{var l;if(!p)return;const{linkAdd:r}=p;if(!(r!=null&&r.link))return;const{link:a}=r,c={objectId:i.value.id,targetType:"Ticket"};let t=e.readQuery({query:d,variables:c});(l=t==null?void 0:t.linkList)!=null&&l.find(u=>u.item.id===a.item.id&&u.type===a.type)||(t={...t,linkList:[...(t==null?void 0:t.linkList)||[],a]},e.writeQuery({query:d,data:t,variables:c}))}}),{errorShowNotification:!1}).send().then(e=>{if(e!=null&&e.linkAdd)return()=>{w({type:F.Success,message:__("Link added successfully")}),S("ticket-link")}});return(o,s)=>(E(),H(O,{"header-title":o.__("Link Tickets"),"header-icon":"link",name:"ticket-link",size:"large","no-close-on-action":"","footer-action-options":h.value},{default:K(()=>[R("div",U,[k(q,{ref_key:"form",ref:m,schema:v,"initial-values":b,"should-autofocus":"",onSubmit:s[0]||(s[0]=e=>C(e))},null,512),k(j,{"customer-id":i.value.customer.id,"internal-ticket-id":i.value.internalId,"selected-ticket-id":f(L),onClickTicket:f(I)},null,8,["customer-id","internal-ticket-id","selected-ticket-id","onClickTicket"])])]),_:1},8,["header-title","footer-action-options"]))}});export{Ut as default};
//# sourceMappingURL=TicketLinksFlyout-D2di-eBe.js.map
