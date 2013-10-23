<div class="${request.getAttribute("attributeClass")!}">
  <#if orderItemShipGroups?has_content>
    <#-- shipping address -->
    <#assign groupIdx = 0>
    <#list orderItemShipGroups as shipGroup>
        <#assign shippingAddress = shipGroup.getRelatedOneCache("PostalAddress")?if_exists>
        <#assign groupNumber = shipGroup.shipGroupSeqId?if_exists>
        <#if shippingAddress?has_content>
         <#include "component://osafe/webapp/osafe/common/address/displayShippingAddress.ftl"/>
        </#if>
      <#assign groupIdx = groupIdx + 1>
    </#list><#-- end list of orderItemShipGroups -->
  </#if>
</div>  
