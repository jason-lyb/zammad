const n=()=>({getTicketData:t=>!t||!t.ticketsCount?null:{count:t.ticketsCount,createLabel:__("Create new ticket for this organization"),createLink:`/tickets/create?organization_id=${t.internalId}`,query:`organization.id: ${t.internalId}`}});export{n as u};
//# sourceMappingURL=useOrganizationTicketsCount-CWW16y9d.js.map
