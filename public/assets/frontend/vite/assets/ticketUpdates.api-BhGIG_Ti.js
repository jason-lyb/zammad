import{n as t}from"./vendor-C11O1Xx8.js";import{T as n}from"./ticketAttributes.api-rqx5ITab.js";import{a as c}from"./apollo-Cj5TVUDk.js";const a=t`
    fragment ticketMention on Mention {
  user {
    id
    internalId
    firstname
    lastname
    fullname
    vip
    outOfOffice
    outOfOfficeStartAt
    outOfOfficeEndAt
    active
    image
  }
  userTicketAccess {
    agentReadAccess
  }
}
    `,o=t`
    fragment referencingTicket on Ticket {
  id
  internalId
  number
  title
  state {
    id
    name
  }
  stateColorCode
}
    `,s=t`
    subscription ticketUpdates($ticketId: ID!, $initial: Boolean = false) {
  ticketUpdates(ticketId: $ticketId, initial: $initial) {
    ticket {
      ...ticketAttributes
      createArticleType {
        id
        name
      }
      mentions(first: 20) {
        totalCount
        edges {
          node {
            ...ticketMention
          }
          cursor
        }
      }
      checklist {
        id
        completed
        incomplete
        total
        complete
      }
      referencingChecklistTickets {
        ...referencingTicket
      }
    }
  }
}
    ${n}
${a}
${o}`;function k(e,i={}){return c(s,e,i)}export{o as R,a as T,s as a,k as u};
//# sourceMappingURL=ticketUpdates.api-BhGIG_Ti.js.map
