<#include "component://osafe/webapp/osafe/includes/CommonMacros.ftl"/>
<#if fieldPurpose?has_content && context.get(fieldPurpose+"PostalAddress")?has_content>
  <#assign postalAddressData = context.get(fieldPurpose+"PostalAddress") />
</#if>
<#if postalAddressData?has_content>
    <#assign countryGeoId = postalAddressData.countryGeoId!"">
</#if>
<#assign  selectedCountry = parameters.get(fieldPurpose+"_COUNTRY")!countryGeoId?if_exists/>
<#if !selectedCountry?has_content>
    <#if defaultCountryGeoMap?exists>
        <#assign selectedCountry = defaultCountryGeoMap.geoId/>
    </#if>
</#if>

<!-- address country entry -->
<#assign mandatory= request.getAttribute("attributeMandatory")!"N"/>
<div class="${request.getAttribute("attributeClass")!}">
    <label for="${fieldPurpose?if_exists}_COUNTRY"><#if mandatory == "Y"><@required/></#if>${uiLabelMap.CountryCaption}</label>
    <select name="${fieldPurpose?if_exists}_COUNTRY" id="js_${fieldPurpose?if_exists}_COUNTRY" class="dependentSelectMaster">
        <#list countryList as country>
            <option value='${country.geoId}' <#if selectedCountry = country.geoId >selected=selected</#if>>${country.get("geoName")?default(country.geoId)}</option>
        </#list>
    </select>
    <input type="hidden" id="${fieldPurpose?if_exists}_COUNTRY_MANDATORY" name="${fieldPurpose?if_exists}_COUNTRY_MANDATORY" value="${mandatory}"/>
    <@fieldErrors fieldName="${fieldPurpose?if_exists}_COUNTRY"/>
    
</div>
