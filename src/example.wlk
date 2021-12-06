/** ¡Éxitos en el parcial! */ 
class UserException inherits Exception{}

object planDeVacunacion {
	const property personas = []
	const property vacunasDisponibles = [paifer, new Larussa(multiplicador = 5), new Larussa(multiplicador = 2), astraLaVistaZeneca, new Combineta(vacunasCombinadas = [new Larussa(multiplicador=2), paifer])]
	
	method costo(){
		const personasAVacunar = personas.filter({persona => not persona.esOutsider(vacunasDisponibles)})
		
		return personasAVacunar.sum({persona => persona.vacunaElegida(vacunasDisponibles).costo(persona)})
	}
	
}


class Persona {

	var property anticuerpos
	var property edad
	var property nombre
	var property dondeVive
	var property tipoDePersona
	var property fechaDeVencimientoVacuna
	const property vacunasAplicadas = []

	method tieneNombrePar() = nombre.size().even()

	method esEspecial() = [ "tierra del fuego", "santa cruz", "neuquen" ].contains(dondeVive.toLowerCase())

	method elige(vacuna) = tipoDePersona.elige(vacuna, self)
	
	method esOutsider(vacunas) = self.vacunaElegida(vacunas).isEmpty()
	
	method vacunaElegida(vacunas) = vacunas.filter({vacuna => self.elige(vacuna)}).min({vacuna => vacuna.costo(self)})
	
	method aplicarVacuna(vacuna){
		anticuerpos = vacuna.anticuerposQueAplica(self)
		fechaDeVencimientoVacuna = vacuna.fechaDeVencimiento(self)
		vacunasAplicadas.add(vacuna)
	}
	
	method cofirmarTurno(vacuna){
		if(not self.elige(vacuna)){
			throw new UserException(message = "La vacuna solicitada no es aplicable para la persona" )
		}
		self.aplicarVacuna(vacuna)
	}
	
}

class Vacuna {

	method costoParticular(persona)

	method costo(persona) = self.costoGeneral(persona) + self.costoParticular(persona)

	method costoGeneral(persona) {
		if (persona.edad() <= 30) {
			return 1000
		}
		return (persona.edad() - 30) * 50
	}

}

object paifer inherits Vacuna {

	method anticuerposQueAplica(persona) = persona.anticuerpos() * 10

	method mesesDeInmunidad(persona) = if (persona.edad() >= 40) 6 else 9

	method fechaDeVencimiento(persona) {
		const hoy = new Date()
		return hoy.plusMonths(self.mesesDeInmunidad(persona))
	}

	override method costoParticular(persona) = if (persona.edad() >= 18) 400 else 100

}

class Larussa inherits Vacuna {

	const property multiplicador
	const property fechaDeHoy = new Date()

	method anticuerposQueAplica(persona) = (persona.anticuerpos() * multiplicador).min(persona.anticuerpos() * 20)

	method fechaDeVencimiento(persona) = new Date(day = 3, month = 3, year = 2022)

	override method costoParticular(persona) = 100 * multiplicador

}

object astraLaVistaZeneca inherits Vacuna {

	method anticuerposQueAplica(persona) = persona.anticuerpos() + 10000

	method mesesDeInmunidad(persona) = if (persona.tieneNombrePar()) 6 else 7

	method fechaDeVencimiento(persona) {
		const hoy = new Date()
		return hoy.plusMonths(self.mesesDeInmunidad(persona))
	}

	override method costoParticular(persona) = if (persona.esEspecial()) 2000 else 0

}

class Combineta inherits Vacuna {

	const property vacunasCombinadas = []

	method cantidadDeVacunas() = vacunasCombinadas.size()

	method anticuerposQueAplica(persona) = vacunasCombinadas.min({vacuna => vacuna.anticuerposQueAplica(persona)}).anticuerposQueAplica(persona)

	method fechaDeVencimiento(persona) {
		const hoy = new Date()
		return vacunasCombinadas.max({ vacuna => (vacuna.fechaDeVencimiento(persona)) - hoy }).fechaDeVencimiento(persona)
	}

	override method costoParticular(persona) = vacunasCombinadas.sum({ vacuna => vacuna.costo(persona)}) + self.cantidadDeVacunas()*100

}

object cualquierosa {
	method elige(vacuna, persona) = true
}

object anticuerposa {
	method elige(vacuna, persona) = vacuna.anticuerposQueAplica(persona) > 100000
}

object inmunidosaFija{
	method elige(vacuna, persona) = vacuna.fechaDeVencimiento(persona) > new Date(day=5, month=3, year=2022)
}

class InmunidosaVariable{
	var property mesesDeInmunidad
	
	method elige(vacuna, persona) = vacuna.fechaDeVencimiento(persona) > new Date().plusMonths(mesesDeInmunidad)
}
