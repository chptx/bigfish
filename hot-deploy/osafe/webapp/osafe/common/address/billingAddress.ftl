<#if billingContactMechAddress?has_content>
   <#-- Billing addresses -->
  <#assign billingAddress = billingContactMechAddress.getRelatedOneCache("PostalAddress")>
  <#if billingAddress?has_content>
     <#include "component://osafe/webapp/osafe/common/address/displayBillingAddress.ftl"/>
  </#if>
 </div>
</#if>