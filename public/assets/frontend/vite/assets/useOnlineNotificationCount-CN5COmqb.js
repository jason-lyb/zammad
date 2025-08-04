import{n as s}from"./vendor-C11O1Xx8.js";import{a as u,S as e}from"./apollo-Cj5TVUDk.js";import{r}from"./vue-oicRkvo0.js";const c=s`
    subscription onlineNotificationsCount {
  onlineNotificationsCount {
    unseenCount
  }
}
    `;function a(n={}){return u(c,{},n)}const p=()=>{const n=r(0),o=new e(a());return o.onResult(i=>{const{data:t}=i;t&&(n.value=t.onlineNotificationsCount.unseenCount)}),{notificationsCountSubscription:o,unseenCount:n}};export{p as u};
//# sourceMappingURL=useOnlineNotificationCount-CN5COmqb.js.map
