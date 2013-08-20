<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" 
    xmlns:core1.0="http://schema.omg.org/spec/CTS2/1.0/Core"
    xmlns:association1.0="http://schema.omg.org/spec/CTS2/1.0/Association"
    xmlns:codesystem1.0="http://schema.omg.org/spec/CTS2/1.0/CodeSystem"
    xmlns:codesystemversion1.0="http://schema.omg.org/spec/CTS2/1.0/CodeSystemVersion"
    xmlns:conceptdomain1.0="http://schema.omg.org/spec/CTS2/1.0/ConceptDomain"
    xmlns:conceptdomainbinding1.0="http://schema.omg.org/spec/CTS2/1.0/ConceptDomainBinding"
    xmlns:entity1.0="http://schema.omg.org/spec/CTS2/1.0/Entity"
    xmlns:map1.0="http://schema.omg.org/spec/CTS2/1.0/MapCatalog"
    xmlns:mapversion1.0="http://schema.omg.org/spec/CTS2/1.0/MapVersion"
    xmlns:stmt1.0="http://schema.omg.org/spec/CTS2/1.0/Statement"
    xmlns:valueset1.0="http://schema.omg.org/spec/CTS2/1.0/ValueSet"
    xmlns:valuesetdefinition1.0="http://schema.omg.org/spec/CTS2/1.0/ValueSetDefinition"
    xmlns:updates1.0="http://schema.omg.org/spec/CTS2/1.0/Updates" 
    
    xmlns:core="http://www.omg.org/spec/CTS2/1.1/Core"
    xmlns:association="http://www.omg.org/spec/CTS2/1.1/Association"
    xmlns:codesystem="http://www.omg.org/spec/CTS2/1.1/CodeSystem"
    xmlns:codesystemversion="http://www.omg.org/spec/CTS2/1.1/CodeSystemVersion"
    xmlns:conceptdomain="http://www.omg.org/spec/CTS2/1.1/ConceptDomain"
    xmlns:conceptdomainbinding="http://www.omg.org/spec/CTS2/1.1/ConceptDomainBinding"
    xmlns:entity="http://www.omg.org/spec/CTS2/1.1/Entity" 
    xmlns:map="http://www.omg.org/spec/CTS2/1.1/MapCatalog"
    xmlns:mapversion="http://www.omg.org/spec/CTS2/1.1/MapVersion"
    xmlns:stmt="http://www.omg.org/spec/CTS2/1.1/Statement" 
    xmlns:valueset="http://www.omg.org/spec/CTS2/1.1/ValueSet"
    xmlns:valuesetdefinition="http://www.omg.org/spec/CTS2/1.1/ValueSetDefinition"
    xmlns:updates="http://www.omg.org/spec/CTS2/1.1/Updates">

    <xsl:output method="xml" indent="yes"/>
    <xsl:strip-space elements="*"/>

    <xsl:variable name="targetNamespace">http://www.omg.org/spec/CTS2/1.1/</xsl:variable>
    <!-- Change this to the appropriate spot on the OMG server once the spec is accepted and published -->
    <xsl:param name="targetSchemaLocation">http://informatics.mayo.edu/cts2/spec/CTS2/1.1/</xsl:param>
    <xsl:variable name="sourceNamespace">http://schema.omg.org/spec/CTS2/1.0/</xsl:variable>
    <xsl:variable name="sourceSchemaLocation">http://www.omg.org/spec/cts2/201206/</xsl:variable>
    
    <xsl:include href="CTS2ConversionUtils.xsl"/>

    <!-- =========================================
        OMG Issue 17318 (GitHub issue #90) - Namespace transformation 
         Part 1: Convert the schemaLocation if present
            Covered in CTS2ConversionUtils.xsl on match schemaLocation
         Part 2: Change all the actual namespaces.
            Covered in CTS2ConversionUtils.xsl generic match template -->


    <!-- =========================================
        OMG Issue 18490 (GitHub issue #118) - AssociationDirectory needs associationID
        No change in transformation, as it is optional and not present in 1.0
        ========================================== -->

    <!-- =========================================
        OMG Issue 18489 (GitHub issue #119) - associationID should optional in Association
        No change in transformation, as it is always present in 1.0
        ========================================== -->

    <!-- =========================================
        OMG Issue 18488 (GitHub issue #120) - include a depth indicator in AssociationGraph
        No change in transformation, as it is not present in 1.0 and is optional in 1.1
        ========================================== -->

    <!-- =========================================
        OMG Issue 18487 (GitHub issue #121) - add optional 'hasOntologyLanguage' and 'includes' to CodeSystemCatalogEntry
        No change in transformation, as it is not present in 1.0 and is optional in 1.1
        ========================================== -->


    <!-- =========================================
        OMG Issue 18479 (GitHub issue #129) - additional options for Entity Read Query
        CodeSystemRole is not present in 1.0, so no transformation necessary
        ========================================== -->

    <!-- =========================================
        OMG Issue 18476 (GitHub issue #134) - no way to get to current resolution from a value set
        Attribute is optional and not present in 1.0, so no transformation necessary
        ========================================== -->


    <!-- =========================================
        OMG Issue 18494 (GitHub issue #136) - parents URI needed in EntityDescription
        If the EntityDescription has parents, add a link to all the parents
        ========================================== -->
    <xsl:template match="entity1.0:parent">
        <xsl:element name="{local-name()}" namespace="{$nsmap/entity}">
            <xsl:apply-templates select="node() | @*"/>
        </xsl:element>
        <xsl:if test="count(following-sibling::entity1.0:parent)=0">
            <xsl:element name="parents" namespace="{$nsmap/entity}">
                <xsl:value-of
                    select="concat(ancestor::entity1.0:EntityDescriptionMsg/core1.0:heading/core1.0:resourceURI, '/parents')"
                />
            </xsl:element>
        </xsl:if>
    </xsl:template>

    <!-- =========================================
        OMG Issue 18474 (GitHub issue #137) - extensible directories, which are constraints on lists
        Issue #
        Constraints are ignored in CTS2 1.0, so client needs to deal with extra if it shows up
        ========================================== -->

    <!-- =========================================
        OMG Issue 18473 (GitHub issue #138) - document URI shouldn't be mandatory in resource description
        Will always be present when going from 1.0 to 1.1.  Remove if it matches the about URI
        ========================================== -->
    <xsl:template match="@documentURI">
        <xsl:if test="not(count(../@about)) or ../@about != .">
            <xsl:attribute name="documentURI">
                <xsl:value-of select="."/>
            </xsl:attribute>
        </xsl:if>
    </xsl:template>

    <!-- =========================================
        OMG Issue 18471 (GitHub issue #140) - sourceAndNotation made optional
        Will always be present in 1.0, so no change required.
        ========================================== -->

    <!-- =========================================
        OMG Issue 18486 (GitHub issue #122)- MapEntry MapFrom and MapTo elements need optional description
        OMG Issue 18470 (GitHub issue #141) - referencedEntity in value set definition should have optional description
        OMG Issue 18532 (GitHub issue #143) - URIAndEntityName should have an optional description
        Never present in 1.0, so no change
        ========================================== -->

    <!-- =========================================
        OMG Issue 18531 (GitHub issue #147) - ResolvedValueSet.member changed to ResolvedValueSet.entry 
        ========================================== -->
    <xsl:template match="valuesetdefinition1.0:member">
        <xsl:element name="entry" namespace="{$nsmap/valuesetdefinition}">
            <xsl:apply-templates select="node() | @* "/>
        </xsl:element>
    </xsl:template>

    <!-- =========================================
        Issue #150 - cardinality of includesResolvedValueSet is [0..1] in ResolvedValueSetHeader.  Should be [0..*]
        CTS2 1.0 services should not be able to fill out more than one, no change.
        ========================================== -->

    <!-- =========================================
        OMG Issue 18542 (GitHub issue #150) - cardinality of includesResolvedValueSet is [0..1] in ResolvedValueSetHeader.  Should be [0..*]
        CTS2 1.0 services should not be able to fill out more than one, no change.
        ========================================== -->

    <!-- =========================================
        OMG Issue 18624 (GitHub issue #157) -AssociationDirectory needs an optional derivation.
        Not present in 1.0, so no change
        ========================================== -->

    <!-- =========================================
        OMG Issue 18682 (GitHub issue #158) - Association derivation should be optional and not have a default
        It is mandatory in 1.0, so not an issue
        ========================================== -->



</xsl:stylesheet>
