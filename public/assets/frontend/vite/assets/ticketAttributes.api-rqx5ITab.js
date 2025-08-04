import{n as e}from"./vendor-C11O1Xx8.js";import{O as t}from"./routes-CgLO9M4y.js";const n=e`
    fragment ticketAttributes on Ticket {
  id
  internalId
  number
  title
  createdAt
  escalationAt
  updatedAt
  updatedBy {
    id
  }
  pendingTime
  owner {
    id
    internalId
    firstname
    lastname
  }
  customer {
    id
    internalId
    firstname
    lastname
    fullname
    phone
    mobile
    image
    vip
    active
    outOfOffice
    outOfOfficeStartAt
    outOfOfficeEndAt
    email
    organization {
      id
      internalId
      name
      active
      objectAttributeValues {
        ...objectAttributeValues
      }
    }
    hasSecondaryOrganizations
    policy {
      update
    }
  }
  organization {
    id
    internalId
    name
    vip
    active
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
    emailAddress {
      name
      emailAddress
    }
  }
  priority {
    id
    name
    defaultCreate
    uiColor
  }
  objectAttributeValues {
    ...objectAttributeValues
  }
  policy {
    update
    agentReadAccess
  }
  tags
  timeUnit
  timeUnitsPerType {
    name
    timeUnit
  }
  subscribed
  preferences
  stateColorCode
  sharedDraftZoomId
  firstResponseEscalationAt
  closeEscalationAt
  updateEscalationAt
  initialChannel
  externalReferences {
    github
    gitlab
  }
}
    ${t}`;export{n as T};
//# sourceMappingURL=ticketAttributes.api-rqx5ITab.js.map
