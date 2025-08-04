import{n as f,u as p}from"./vendor-C11O1Xx8.js";import{e as d,M as g,N as L,c as M}from"./apollo-Cj5TVUDk.js";import{X as v}from"./overviewAttributes.api-C09LSZ8O.js";import{b as N}from"./routes-CgLO9M4y.js";import{r as S,c as n}from"./vue-oicRkvo0.js";const _=f`
    mutation userCurrentLocale($locale: String!) {
  userCurrentLocale(locale: $locale) {
    success
    errors {
      ...errors
    }
  }
}
    ${v}`;function y(t={}){return d(_,t)}const C="https://translations.zammad.org/",U=()=>{const t=S(!1),l=new g(y({}),{errorNotificationMessage:__("The language could not be updated.")}),{notify:u}=M(),r=N(),{localeData:s,locales:a}=p(r),{setLocale:c}=r,i=n({get:()=>{var e;return((e=s.value)==null?void 0:e.locale)??"en"},set:e=>{var o;!e||((o=s.value)==null?void 0:o.locale)===e||(t.value=!0,Promise.all([c(e),l.send({locale:e})]).then(()=>{u({id:"locale-update",message:__("Profile language updated successfully."),type:L.Success})}).finally(()=>{t.value=!1}))}}),m=n(()=>{var e;return((e=a==null?void 0:a.value)==null?void 0:e.map(o=>({label:o.name,value:o.locale})))||[]});return{translation:{link:C},isSavingLocale:t,modelCurrentLocale:i,localeOptions:m}};export{U as u};
//# sourceMappingURL=useLocaleUpdate-BuNp3bsA.js.map
