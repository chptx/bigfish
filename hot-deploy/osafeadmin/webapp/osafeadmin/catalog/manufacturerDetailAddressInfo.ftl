<!-- start manufacturerDetailAddressInfo.ftl -->
<script type="text/javascript">
    jQuery(document).ready(function () {
        if (jQuery('#${fieldPurpose?if_exists}_country')) {
            if(!jQuery('#${fieldPurpose?if_exists}_StateListExist').length) {
                getAssociatedStateList('${fieldPurpose?if_exists}_country', '${fieldPurpose?if_exists}_state', '${fieldPurpose?if_exists}_STATES');
            }
            getAddressFormat("${fieldPurpose?if_exists}");
            jQuery('#${fieldPurpose?if_exists}_country').change(function(){
                getAssociatedStateList('${fieldPurpose?if_exists}_country', '${fieldPurpose?if_exists}_state', '${fieldPurpose?if_exists}_STATES');
                getAddressFormat("${fieldPurpose?if_exists}");
            });
        }
        if (jQuery('#billing_addressEntry').length && jQuery('#shipping_addressEntry').length && jQuery('#isSameAsBilling').length && jQuery('#shipping_addressSection').length) {
          copyAddress('billing', jQuery('#billing_addressEntry'), 'shipping', jQuery('#shipping_addressSection'), jQuery('#isSameAsBilling'), true);
        }
    });
</script>
<#if postalAddress?has_content>
    <#assign contactMechId = postalAddress.contactMechId!"">
    <#assign address1 = postalAddress.address1!"">
    <#assign address2 = postalAddress.address2!"">
    <#assign city = postalAddress.city!"">
    <#assign stateProvinceGeoId = postalAddress.stateProvinceGeoId!"">
    <#assign countryGeoId = postalAddress.countryGeoId!"">
    <#assign postalCode = postalAddress.postalCode!"">
    <#if postalCode?has_content && postalCode == '_NA_'>
      <#assign postalCode = "">
    </#if>
</#if>
<!-- address state entry -->
<#assign  selectedCountry = parameters.get("${fieldPurpose?if_exists}_country")!countryGeoId?if_exists/>
<#if !selectedCountry?has_content>
    <#if defaultCountryGeoMap?exists>
        <#assign selectedCountry = defaultCountryGeoMap.geoId/>
    </#if>
</#if>
<#if parameters.get("${fieldPurpose?if_exists}_state")?has_content>
  <#assign selectedState = parameters.get("${fieldPurpose?if_exists}_state")!/>
<#else>
  <#assign selectedState = stateProvinceGeoId!""/>
</#if>
<#assign countryList = Static["com.osafe.util.OsafeAdminUtil"].getCountryList(request)/>
<#assign selectedCountry = parameters.countryGeoId!countryGeoId!COUNTRY_DEFAULT!""/>

<#if mode?has_content && mode="edit">
    <input type="hidden" name="contactMechId" id="contactMechId" value="${contactMechId!""}"/>
</#if>
<#if COUNTRY_MULTI?has_content && Static["com.osafe.util.OsafeAdminUtil"].isProductStoreParmTrue(COUNTRY_MULTI)>
  <div class="infoRow row">
    <div class="infoEntry long">
      <div class="infoCaption">
        <label><span class="required">*</span>${uiLabelMap.CountryCaption}</label>
      </div>
      <div class="infoValue">
        <select name="user_country" id="user_country">
          <#if countryList?has_content>
            <#list countryList as country>
              <option value='${country.geoId}' <#if selectedCountry = country.geoId >selected=selected</#if>>${country.get("geoName")?default(country.geoId)}</option>
            </#list>
          </#if>
        </select>
      </div>
    </div>
  </div>
<#else>
  <input type="hidden" name="countryGeoId" id="countryGeoId" value="${selectedCountry}"/>
</#if> 
<!-- address Line1 entry -->
<div class = "addressInfoAddress1">
    <div class="infoRow">
        <div class="infoEntry">
            <div class="infoCaption">
                <label><span class="required">*</span>${uiLabelMap.Address1Caption}</label>
            </div>
            <div class="infoValue">
                <input type="text" maxlength="255" class="address" name="${fieldPurpose?if_exists}_address1" id="${fieldPurpose?if_exists}_address1" value="${parameters.get("${fieldPurpose?if_exists}_address1")!address1!""}" />
            </div>
        </div>
    </div>
</div>
<!-- address Line2 entry -->
<div class = "addressInfoAddress2">
    <div class="infoRow">
        <div class="infoEntry">
            <div class="infoCaption">
                <label>${uiLabelMap.Address2Caption}</label>
            </div>
            <div class="infoValue">
                <input type="text" maxlength="255" class="address" name="${fieldPurpose?if_exists}_address2" id="${fieldPurpose?if_exists}_address2" value="${parameters.get("${fieldPurpose?if_exists}_address2")!address2!""}" />
            </div>
        </div>
    </div>
</div>
<!-- address city entry -->
<div class = "addressInfoCityTown">
    <div class="infoRow">
        <div class="infoEntry">
            <div class="infoCaption">
                <label>
				    <span class="required">*</span>
                    <span>${uiLabelMap.TownOrCityCaption}</span>
                </label>
            </div>
            <div class="infoValue">
                <input type="text" maxlength="100" class="city" name="${fieldPurpose?if_exists}_city" id="${fieldPurpose?if_exists}_city" value="${parameters.get("${fieldPurpose?if_exists}_city")!city!""}" />
            </div>
        </div>
    </div>
</div>
<div class = "addressInfoStateProvince">
    <div class="infoRow" id="${fieldPurpose?if_exists}_STATES">
        <div class="infoEntry">
            <div class="infoCaption">
                <label>
				    <span class="required">*</span>
                    <span>${uiLabelMap.StateOrProvinceCaption}</span>
                </label>
            </div>
            <div class="infoValue">
                <select id="${fieldPurpose?if_exists}_state" name="${fieldPurpose?if_exists}_state" class="select ${fieldPurpose?if_exists}_country">
                    <#list countryList as country>
                        <#if country.geoId == selectedCountry>
                          <#assign stateMap = dispatcher.runSync("getAssociatedStateList", Static["org.ofbiz.base.util.UtilMisc"].toMap("countryGeoId", country.geoId, "userLogin", userLogin, "listOrderBy", "geoCode"))/>
                          <#assign stateList = stateMap.stateList />
                          <#-- assign stateList = Static["org.ofbiz.common.CommonWorkers"].getAssociatedStateList(delegator, country.geoId) /-->
                          <#if stateList?has_content>
                              <#list stateList as state>
                                  <option value="${state.geoId!}" <#if selectedState?exists && selectedState == state.geoId!>selected=selected</#if>>${state.geoName?default(state.geoId!)}</option>
                              </#list>
                          </#if>
                        </#if>
                    </#list>
                </select>
                <#if stateList?has_content>
                    <input type="hidden" name="${fieldPurpose?if_exists}_StateListExist" value="" id="${fieldPurpose?if_exists}_StateListExist"/>
                </#if>
            </div>
        </div>
    </div>
</div>
<!-- address zip entry -->
<div class = "addressInfoZipPostcode">
    <div class="infoRow">
        <div class="infoEntry">
            <div class="infoCaption">
                <label>
					<span class="required">*</span>
                    <span>${uiLabelMap.ZipOrPostalCodeCaption}</span>
                </label>
            </div>
            <div class="infoValue">
                <input type="text" maxlength="60" class="postalCode" name="${fieldPurpose?if_exists}_postalCode" id="${fieldPurpose?if_exists}_postalCode" value="${parameters.get("${fieldPurpose?if_exists}_postalCode")!postalCode!""}" />
            </div>
        </div>
    </div>
</div>
<!-- end manufacturerDetailAddressInfo.ftl -->


