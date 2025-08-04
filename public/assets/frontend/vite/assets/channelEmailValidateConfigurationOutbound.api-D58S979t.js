import{u as l}from"./useForm-CUKec4n5.js";import{s as d,d as m}from"./vue-oicRkvo0.js";import{n as p}from"./vendor-C11O1Xx8.js";import{X as c}from"./overviewAttributes.api-C09LSZ8O.js";import{e as g}from"./apollo-Cj5TVUDk.js";const O=()=>{const e=d(),{updateFieldValues:t,values:s,formSetErrors:n,onChangedField:u}=l(e),r=m({sslVerify:{}});u("port",a=>{const o=!!(a&&!(a==="465"||a==="587"));r.sslVerify={disabled:o},t({sslVerify:!o})});const i=[{isLayout:!0,element:"div",attrs:{class:"grid grid-cols-2 gap-y-2.5 gap-x-3"},children:[{type:"group",name:"outbound",isGroupOrList:!0,children:[{name:"adapter",label:__("Send mails via"),type:"select",outerClass:"col-span-2",required:!0},{if:'$values.adapter === "smtp"',isLayout:!0,element:"div",attrs:{class:"grid grid-cols-2 gap-y-2.5 gap-x-3 col-span-2"},children:[{name:"host",label:__("Host"),type:"text",outerClass:"col-span-2",props:{maxLength:120},required:!0},{name:"user",label:__("User"),type:"text",outerClass:"col-span-2",props:{maxLength:120},required:!0},{name:"password",label:__("Password"),type:"password",outerClass:"col-span-2",props:{maxLength:120},required:!0},{name:"port",label:__("Port"),type:"text",outerClass:"col-span-1",validation:"number",props:{maxLength:6},required:!0},{name:"sslVerify",label:__("SSL verification"),type:"toggle",outerClass:"col-span-1",wrapperClass:"mt-6",value:!0,props:{variants:{true:"yes",false:"no"}}}]}]}]}];return{formEmailOutbound:e,emailOutboundSchema:i,emailOutboundFormChangeFields:r,updateEmailOutboundFieldValues:t,formEmailOutboundSetErrors:n,formEmailOutboundValues:s}},f=p`
    mutation channelEmailValidateConfigurationOutbound($outboundConfiguration: ChannelEmailOutboundConfigurationInput!, $emailAddress: String!) {
  channelEmailValidateConfigurationOutbound(
    outboundConfiguration: $outboundConfiguration
    emailAddress: $emailAddress
  ) {
    success
    errors {
      ...errors
    }
  }
}
    ${c}`;function _(e={}){return g(f,e)}export{_ as a,O as u};
//# sourceMappingURL=channelEmailValidateConfigurationOutbound.api-D58S979t.js.map
