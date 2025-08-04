import{n as e}from"./vendor-C11O1Xx8.js";import{X as t}from"./overviewAttributes.api-C09LSZ8O.js";import{e as a}from"./apollo-Cj5TVUDk.js";const u=e`
    mutation userCurrentAvatarAdd($images: AvatarInput!) {
  userCurrentAvatarAdd(images: $images) {
    avatar {
      id
      default
      deletable
      initial
      imageFull
      imageResize
      imageHash
      createdAt
      updatedAt
    }
    errors {
      ...errors
    }
  }
}
    ${t}`;function d(r={}){return a(u,r)}const s=e`
    mutation userCurrentAvatarDelete($id: ID!) {
  userCurrentAvatarDelete(id: $id) {
    success
    errors {
      ...errors
    }
  }
}
    ${t}`;function m(r={}){return a(s,r)}export{m as a,d as u};
//# sourceMappingURL=userCurrentAvatarDelete.api-BdjimpWn.js.map
