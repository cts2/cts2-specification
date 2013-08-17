<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.1" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" 
    xmlns:core="http://schema.omg.org/spec/CTS2/1.0/Core"
    xmlns:association="http://schema.omg.org/spec/CTS2/1.0/Association"
    xmlns:codesystem="http://schema.omg.org/spec/CTS2/1.0/CodeSystem"
    xmlns:codesystemversion="http://schema.omg.org/spec/CTS2/1.0/CodeSystemVersion"
    xmlns:conceptdomain="http://schema.omg.org/spec/CTS2/1.0/ConceptDomain"
    xmlns:conceptdomainbinding="http://schema.omg.org/spec/CTS2/1.0/ConceptDomainBinding"
    xmlns:entity="http://schema.omg.org/spec/CTS2/1.0/Entity" 
    xmlns:map="http://schema.omg.org/spec/CTS2/1.0/MapCatalog"
    xmlns:mapversion="http://schema.omg.org/spec/CTS2/1.0/MapVersion"
    xmlns:stmt="http://schema.omg.org/spec/CTS2/1.0/Statement"
    xmlns:valueset="http://schema.omg.org/spec/CTS2/1.0/ValueSet"
    xmlns:valuesetdefinition="http://schema.omg.org/spec/CTS2/1.0/ValueSetDefinition"
    xmlns:updates="http://schema.omg.org/spec/CTS2/1.0/Updates" 
    
    xmlns:core1.1="http://www.omg.org/spec/CTS2/1.1/Core"
    xmlns:association1.1="http://www.omg.org/spec/CTS2/1.1/Association"
    xmlns:codesystem1.1="http://www.omg.org/spec/CTS2/1.1/CodeSystem"
    xmlns:codesystemversion1.1="http://www.omg.org/spec/CTS2/1.1/CodeSystemVersion"
    xmlns:conceptdomain1.1="http://www.omg.org/spec/CTS2/1.1/ConceptDomain"
    xmlns:conceptdomainbinding1.1="http://www.omg.org/spec/CTS2/1.1/ConceptDomainBinding"
    xmlns:entity1.1="http://www.omg.org/spec/CTS2/1.1/Entity" 
    xmlns:map1.1="http://www.omg.org/spec/CTS2/1.1/MapCatalog"
    xmlns:mapversion1.1="http://www.omg.org/spec/CTS2/1.1/MapVersion"
    xmlns:stmt1.1="http://www.omg.org/spec/CTS2/1.1/Statement"
    xmlns:valueset1.1="http://www.omg.org/spec/CTS2/1.1/ValueSet"
    xmlns:valuesetdefinition1.1="http://www.omg.org/spec/CTS2/1.1/ValueSetDefinition"
    xmlns:updates1.1="http://www.omg.org/spec/CTS2/1.1/Updates">
    
    <!-- This file is designed to be imported into a larger conversion package.  The importing package
        needs to supply the following variables:
        
            targetNamespace  - the target namespace prefix (output)
            targetSchemaLocation  - the root of the target schema files
            sourceNamespace  - the source namespace prefix (input)
            sourceSchemaLocation - the root of the source schema files
      -->

    
    <!-- List of modules used in CTS2 -->
    <xsl:variable name="modules">
        <core>Core</core>
        <association>Association</association>
        <codesystem>CodeSystem</codesystem>
        <codesystemversion>CodeSystemVersion</codesystemversion>
        <conceptdomain>ConceptDomain</conceptdomain>
        <conceptdomainbinding>ConceptDomainBinding</conceptdomainbinding>
        <entity>Entity</entity>
        <map>MapCatalog</map>
        <mapversion>MapVersion</mapversion>
        <statement>Statement</statement>
        <valueset>ValueSet</valueset>
        <valuesetdefinition>ValueSetDefinition</valuesetdefinition>
        <updates>Updates</updates>
    </xsl:variable>
    
    <!-- A map between module name and the target namespace -->
    <xsl:variable name="nsmap">
        <xsl:for-each select="$modules/*">
            <xsl:element name="{name()}">
                <xsl:value-of select="concat($targetNamespace,.)"/>
            </xsl:element>
        </xsl:for-each>
    </xsl:variable>
    
    <!-- Adjust the schemaLocation to reference the target namespace -->
    <xsl:template match="@xsi:schemaLocation">
        <xsl:attribute name="xsi:schemaLocation">
            <xsl:choose>
                <xsl:when test="starts-with(.,$sourceNamespace)">
                    <xsl:value-of select="$targetNamespace"/>
                    <xsl:value-of select="substring-before(substring-after(.,$sourceNamespace),' ')"/>
                    <xsl:text> </xsl:text>
                    <xsl:value-of select="$targetSchemaLocation"/>
                    <xsl:value-of select="normalize-space(substring-after(.,$sourceSchemaLocation))"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="."/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:attribute>
    </xsl:template>
    
    <!-- Default map to transform namespace -->
    <xsl:template match="node() | @* ">
        <xsl:call-template name="changeNamespace"/>
    </xsl:template>
    
    <xsl:template name="changeNamespace">
        <xsl:choose>
            <xsl:when test="starts-with(namespace-uri(), $sourceNamespace)">
                <xsl:variable name="module">
                    <xsl:value-of select="substring-after(namespace-uri(),$sourceNamespace)"/>
                </xsl:variable>
                <xsl:element name="{local-name()}" namespace="{$targetNamespace}{$module}">
                    <xsl:apply-templates select="node() | @* "/>
                </xsl:element>
            </xsl:when>
            <xsl:otherwise>
                <xsl:copy>
                    <xsl:apply-templates select="node() | @* "/>
                </xsl:copy>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    
</xsl:stylesheet>