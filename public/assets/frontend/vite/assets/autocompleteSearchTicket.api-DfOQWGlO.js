import{n as e}from"./vendor-C11O1Xx8.js";import"./apollo-Cj5TVUDk.js";const o=e`
    query autocompleteSearchTicket($input: AutocompleteSearchTicketInput!) {
  autocompleteSearchTicket(input: $input) {
    value
    label
    labelPlaceholder
    heading
    headingPlaceholder
    disabled
    icon
    ticket {
      id
      number
      internalId
      state {
        id
        name
      }
      stateColorCode
    }
  }
}
    `;export{o as A};
//# sourceMappingURL=autocompleteSearchTicket.api-DfOQWGlO.js.map
