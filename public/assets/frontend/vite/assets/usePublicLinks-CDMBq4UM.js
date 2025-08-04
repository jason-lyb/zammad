import{n as e}from"./vendor-C11O1Xx8.js";import{u as l,Q as b}from"./apollo-Cj5TVUDk.js";import{c as p}from"./vue-oicRkvo0.js";const t=e`
    fragment publicLinkAttributes on PublicLink {
  id
  link
  title
  description
  newTab
}
    `,k=e`
    query publicLinks($screen: EnumPublicLinksScreen!) {
  publicLinks(screen: $screen) {
    ...publicLinkAttributes
  }
}
    ${t}`;function o(i,n={}){return l(k,i,n)}const L=e`
    subscription publicLinkUpdates($screen: EnumPublicLinksScreen!) {
  publicLinkUpdates(screen: $screen) {
    publicLinks {
      ...publicLinkAttributes
    }
  }
}
    ${t}`,f=i=>{const n=new b(o({screen:i}));return n.subscribeToMore({document:L,variables:{screen:i},updateQuery(r,{subscriptionData:u}){var c;const s=(c=u.data.publicLinkUpdates)==null?void 0:c.publicLinks;return s?{publicLinks:s}:null}}),{links:p(()=>{var u;return((u=n.result().value)==null?void 0:u.publicLinks)||[]})}};export{f as u};
//# sourceMappingURL=usePublicLinks-CDMBq4UM.js.map
