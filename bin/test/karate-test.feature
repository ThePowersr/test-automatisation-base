Feature: Obtener todos los super héroes

  Background:
    * url 'http://bp-se-test-cabcd9b246a5.herokuapp.com/aparraga'
    * configure ssl = true

  Scenario: Obtener todos los super héroes
    Given path 'api/characters'
    When method get
    Then status 200
    * print response

  Scenario: Obtener todos los super Heroes y revisar que dentro exista uno en concreto
    Given path 'api/characters'
    When method get
    Then status 200
    * def result = $[?(@.name == 'Iron Man')]
    * match result[0].name == 'Iron Man'

  Scenario: Obtener un super héroe por ID
    * def responseHero = 
    """
      {
        "id": 1,
        "name": "Iron Man",
        "alterego": "Tony Stark",
        "description": "Cientifico",
        "powers": [
            "armor"
        ]
      }
    """
    Given path 'api/characters/1'
    When method get
    Then status 200
    And match response == responseHero

  Scenario: Obtener un personaje con id que no existe
    Given path 'api/characters/9999'
    When method get
    Then status 404
    And match response.error == "Character not found"


  

  Scenario: Crear un personaje
    * def newHero = 
    """
      {
        "name": "Blue Marvel",
        "alterego": "Adán Bernard Brashear",
        "description": "Cientifico",
        "powers": ["living reactor"]
      }
    """
    Given path 'api/characters'
    And request newHero
    When method post
    Then status 201
    * print response
    * karate.set('responseCreateHero', response)
    * print karate.get('responseCreateHero')
    * print response
    And match response.name == newHero.name

  Scenario: Crear un personaje con el nombre duplicado
    * def newHero = 
    """
      {
        "name": "Blue Marvel",
        "alterego": "Adán Bernard Brashear",
        "description": "Cientifico",
        "powers": ["living reactor"]
      }
    """
    Given path 'api/characters'
    And request newHero
    When method post
    Then status 400
    And match response.error == 'Character name already exists'

  Scenario: Crear un personaje con campos vacios
    * def newHero = 
    """
      {
        "name": "",
        "alterego": "",
        "description": "",
        "powers": []
      }
    """
    * def responseError = 
    """
      {
        "name": "Name is required",
        "description": "Description is required",
        "powers": "Powers are required",
        "alterego": "Alterego is required"
      }
    """
    Given path 'api/characters'
    And request newHero
    When method post
    Then status 400
    And match response == responseError

  Scenario: Actualizar un personaje
    * def updateHero = 
    """
      {
        "name": "Blue Marvel",
        "alterego": "Adán Bernard Brashear",
        "description": "Cientifico actualizado",
        "powers": ["living reactor"]
      }
    """
    Given path 'api/characters'
    When method get
    Then status 200
    * def characterToModified = $[?(@.name == 'Blue Marvel')]
    Given path 'api/characters/' + characterToModified[0].id
    And request updateHero
    When method put
    Then status 200
    * match response.name == updateHero.name
    * match response.alterego == updateHero.alterego
    * match response.description == updateHero.description
    * match response.powers == updateHero.powers


  Scenario: Eliminar un personaje 
    Given path 'api/characters'
    When method get
    Then status 200
    * def charaterToDelete = $[?(@.name == 'Blue Marvel')]
    Given path 'api/characters/' + charaterToDelete[0].id
    When method delete
    Then status 204

    Scenario: Eliminar un personaje que no existe
      Given path 'api/characters/9999'
      When method delete
      Then status 404