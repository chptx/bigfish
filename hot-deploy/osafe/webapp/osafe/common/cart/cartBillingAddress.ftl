<#if billingAddress?has_content>
 <div class="${request.getAttribute("attributeClass")!}">
     <#include "component://osafe/webapp/osafe/common/address/displayBillingAddress.ftl"/>
 </div>
</#if>