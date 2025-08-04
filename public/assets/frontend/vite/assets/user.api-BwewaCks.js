import{n as e}from"./vendor-C11O1Xx8.js";import{O as r}from"./routes-CgLO9M4y.js";import{u as a}from"./apollo-Cj5TVUDk.js";const s=e`
    fragment userDetailAttributes on User {
  id
  internalId
  firstname
  lastname
  fullname
  outOfOffice
  outOfOfficeStartAt
  outOfOfficeEndAt
  image
  email
  web
  vip
  phone
  mobile
  fax
  note
  active
  objectAttributeValues {
    ...objectAttributeValues
  }
  organization {
    id
    internalId
    name
    active
    vip
    ticketsCount {
      open
      closed
    }
  }
  secondaryOrganizations(first: $secondaryOrganizationsCount) {
    edges {
      node {
        id
        internalId
        active
        name
      }
    }
    totalCount
  }
  hasSecondaryOrganizations
  ticketsCount {
    open
    closed
  }
}
    ${r}`,i=e`
    query user($userId: ID, $userInternalId: Int, $secondaryOrganizationsCount: Int) {
  user(user: {userId: $userId, userInternalId: $userInternalId}) {
    ...userDetailAttributes
    policy {
      update
    }
  }
}
    ${s}`;function d(t={},n={}){return a(i,t,n)}export{s as U,d as u};
//# sourceMappingURL=user.api-BwewaCks.js.map
