import{e as m,M as d,N as o,U as k,c as g}from"./apollo-Cj5TVUDk.js";import{n as p}from"./vendor-C11O1Xx8.js";import{T as f}from"./ticketAttributes.api-rqx5ITab.js";import{X as C,Z as u}from"./overviewAttributes.api-C09LSZ8O.js";const I=p`
    mutation ticketCustomerUpdate($ticketId: ID!, $input: TicketCustomerUpdateInput!) {
  ticketCustomerUpdate(ticketId: $ticketId, input: $input) {
    ticket {
      ...ticketAttributes
    }
    errors {
      ...errors
    }
  }
}
    ${f}
${C}`;function T(r={}){return m(I,r)}const M=(r,t)=>{const{notify:i}=g(),n=new d(T());return{changeCustomer:async s=>{var a;const c={customerId:u("User",s.customer_id)};s.organization_id&&(c.organizationId=u("Organization",s.organization_id));try{const e=await n.send({ticketId:r.value.id,input:c});if(e)return(a=t==null?void 0:t.onSuccess)==null||a.call(t),i({id:"ticket-customer-updated",type:o.Success,message:__("Ticket customer updated successfully.")}),e}catch(e){e instanceof k&&i({id:"ticket-customer-update-error",message:e.generalErrors[0],type:o.Error})}}}};export{M as u};
//# sourceMappingURL=useTicketChangeCustomer-gjGu9BEY.js.map
