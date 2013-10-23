<#if shippingAddress?has_content && ((!isStorePickUp?exists) || isStorePickUp=="N")>
    <div class="${request.getAttribute("attributeClass")!}">
         <#include "component://osafe/webapp/osafe/common/address/displayShippingAddress.ftl"/>
    </div>
</#if>