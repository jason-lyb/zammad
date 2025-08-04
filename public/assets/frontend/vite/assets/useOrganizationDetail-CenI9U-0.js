import{n as r,u as O}from"./vendor-C11O1Xx8.js";import{a$ as g,Z as p,b0 as v,n as $}from"./overviewAttributes.api-C09LSZ8O.js";import{u as M,Q as A}from"./apollo-Cj5TVUDk.js";import{c as i,r as C}from"./vue-oicRkvo0.js";const l=r`
    fragment organizationMembers on Organization {
  allMembers(first: $membersCount) {
    edges {
      node {
        id
        internalId
        image
        firstname
        lastname
        fullname
        email
        phone
        outOfOffice
        outOfOfficeStartAt
        outOfOfficeEndAt
        active
        vip
      }
    }
    totalCount
  }
}
    `,D=r`
    query organization($organizationId: ID, $organizationInternalId: Int, $membersCount: Int) {
  organization(
    organization: {organizationId: $organizationId, organizationInternalId: $organizationInternalId}
  ) {
    policy {
      update
    }
    ...organizationAttributes
    ...organizationMembers
  }
}
    ${g}
${l}`;function y(t={},o={}){return M(D,t,o)}const Q=r`
    subscription organizationUpdates($organizationId: ID!, $membersCount: Int) {
  organizationUpdates(organizationId: $organizationId) {
    organization {
      ...organizationAttributes
      ...organizationMembers
    }
  }
}
    ${g}
${l}`,j=(t,o,m)=>{const z=i(()=>{if(t.value)return p("Organization",t.value)}),s=C(3),a=new A(y(()=>({organizationInternalId:t.value,membersCount:3}),()=>({enabled:!!t.value,fetchPolicy:m})),{errorCallback:o});a.subscribeToMore(()=>({document:Q,variables:{organizationId:z.value,membersCount:s.value}}));const c=a.result(),b=a.loading(),e=i(()=>{var n;return(n=c.value)==null?void 0:n.organization}),d=()=>{var u;const n=(u=e.value)==null?void 0:u.internalId;n&&a.refetch({organizationInternalId:n,membersCount:null}).then(()=>{s.value=null})},{viewScreenAttributes:f}=O(v()),I=i(()=>{var n;return $((n=e.value)==null?void 0:n.allMembers)||[]});return{loading:b,organizationQuery:a,organization:e,objectAttributes:f,organizationMembers:I,loadAllMembers:d}};export{j as u};
//# sourceMappingURL=useOrganizationDetail-CenI9U-0.js.map
