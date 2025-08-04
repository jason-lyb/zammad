import{n as t}from"./vendor-C11O1Xx8.js";import{U as e}from"./routes-CgLO9M4y.js";import{X as s}from"./overviewAttributes.api-C09LSZ8O.js";import{e as n}from"./apollo-Cj5TVUDk.js";const o=t`
    mutation userAdd($input: UserInput!, $sendInvite: Boolean) {
  userAdd(input: $input, sendInvite: $sendInvite) {
    user {
      ...userAttributes
    }
    errors {
      ...errors
    }
  }
}
    ${e}
${s}`;function d(r={}){return n(o,r)}export{d as u};
//# sourceMappingURL=add.api-CxwFhgGn.js.map
