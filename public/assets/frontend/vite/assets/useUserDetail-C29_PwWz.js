import{n as v,u as b}from"./vendor-C11O1Xx8.js";import{U as p,u as y}from"./user.api-BwewaCks.js";import{Z as f,a_ as U,n as z}from"./overviewAttributes.api-C09LSZ8O.js";import{Q as O}from"./apollo-Cj5TVUDk.js";import{c as t,r as I}from"./vue-oicRkvo0.js";const A=v`
    subscription userUpdates($userId: ID!, $secondaryOrganizationsCount: Int) {
  userUpdates(userId: $userId) {
    user {
      ...userDetailAttributes
    }
  }
}
    ${p}`,$=(e,n,u)=>{const i=t(()=>{if(e.value)return f("User",e.value)}),o=I(3),s=new O(y(()=>({userInternalId:e.value,secondaryOrganizationsCount:3}),()=>({enabled:!!e.value,fetchPolicy:u})),{errorCallback:n});s.subscribeToMore(()=>({document:A,variables:{userId:i.value,secondaryOrganizationsCount:o.value}}));const c=()=>{s.refetch({userInternalId:e.value,secondaryOrganizationsCount:null}).then(()=>{o.value=null})},l=s.result(),d=s.loading(),a=t(()=>{var r;return(r=l.value)==null?void 0:r.user}),{viewScreenAttributes:m}=b(U()),g=t(()=>{var r;return z((r=a.value)==null?void 0:r.secondaryOrganizations)});return{loading:d,user:a,userQuery:s,objectAttributes:m,secondaryOrganizations:g,loadAllSecondaryOrganizations:c}};export{$ as u};
//# sourceMappingURL=useUserDetail-C29_PwWz.js.map
