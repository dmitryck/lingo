

module RoadNames
  class Road
    property :number, :interstate, :direction, :business
    @interstate = false
    @business = false
  end

  class RoadParser < Lingo::Parser
    # Match a string:
    rule(:interstate) { str("I-") }
    rule(:business) { str("B") }

    # Match a regex:
    rule(:digit) { match(/\d/) }
    # Express repetition with `.repeat`
    rule(:number) { digit.repeat }

    rule(:north) { str("N") }
    rule(:south) { str("S") }
    rule(:east) { str("E") }
    rule(:west) { str("W") }
    # Compose rules by name
    # Express alternation with |
    rule(:direction) { north | south | east | west }

    # Express sequence with >>
    # Express optionality with `.maybe`
    # Name matched strings with `.as`
    rule(:road_name) {
      interstate.as(:interstate).maybe >>
        number.as(:number) >>
        direction.as(:direction).maybe >>
        business.as(:business).maybe
    }
    # You MUST name a starting rule:
    root(:road_name)
  end

  class RoadVisitor < Lingo::Visitor
    getter :road
    def initialize
      @road = Road.new
    end

    # When you find a named node, you can do something with it.
    # You can access the current visitor as `visitor`
    enter(:interstate) {
      # since we found this node, this is a business route
      visitor.road.interstate = true
    }

    # You can access the named Lingo::Node as `node`.
    # Get the matched string with `.full_value`
    enter(:number) {
      visitor.road.number = node.full_value.to_i
    }

    enter(:direction) {
      visitor.road.direction = node.full_value
    }

    enter(:business) {
      visitor.road.business = true
    }
  end

  def self.parse_road(input_str)
    ast = RoadParser.parse(input_str)
    visitor = RoadVisitor.new
    visitor.visit(ast)
    visitor.road
  end
end