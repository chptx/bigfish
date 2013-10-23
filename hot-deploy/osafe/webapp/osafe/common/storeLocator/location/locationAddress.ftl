<li class="${request.getAttribute("attributeClass")!}">
    <div>
      <span>
        <ul class="displayList">
	  	    <li>
            <#if storeRow.address1?has_content>
              <span class="storeAdd1">${storeRow.address1!""},</span>
            </#if>
            <#if storeRow.address2?has_content>
              <span class="storeAdd2">${storeRow.address2!""},</span>
            </#if>
            <#if storeRow.address3?has_content>
              <span class="storeAdd3">${storeRow.address3!""},</span>
            </#if>
            <#if storeRow.city?has_content>
              <span class="storeCity">${storeRow.city!""},</span>
            </#if>
            <#if storeRow.stateProvinceGeoId?has_content>
              <span class="storeState">${storeRow.stateProvinceGeoId!""}</span>
            </#if>
            <#if storeRow.postalCode?has_content>
              <span class="storeZip">${storeRow.postalCode!""}</span>
            </#if>
          </li>
        </ul>
       </span>
    </div>
</li>