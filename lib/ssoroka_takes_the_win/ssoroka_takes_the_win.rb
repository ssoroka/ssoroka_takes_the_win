module SsorokaTakesTheWin

  # Battleship Player
  #
  # Battleship is board game between two players.  See http://en.wikipedia.org/wiki/Battleship for more information and
  # game rules.
  #
  # A player represents the conputer AI to play a game of Battleship.  It should know how to place ships and target
  # the opponents ships.
  #
  # This version of Battleship is played on a 10 x 10 grid where rows are labled by the letters A - J and
  # columns are labled by the numbers 1 - 10.  At the start of the game, each player will be asked for ship placements.
  # Once the ships are placed, play proceeeds by each player targeting one square on their opponents map.  A player
  # may only target one square, reguardless of whether it resulted in a hit or not, before changing turns with her opponent.
  #
  class SsorokaTakesTheWin
    
    # This method is called at the beginning of each game.  A player may only be instantiated once and used to play many games.
    # So new_game should reset any internal state acquired in previous games so that it is prepared for a new game.
    #
    # The name of the opponent player is passed in.  This allows for the possibility to learn opponent strategy and
    # play the game differently based on the opponent.
    #
    def new_game(opponent_name)
      reset
    end

    # Returns the placement of the carrier. A carrier consumes 5 squares.
    #
    # The return value is a string that describes the placements of the ship.
    # The placement string must be in the following format:
    #
    #   "#{ROW}#{COL} #{ORIENTATION}"
    #
    # eg
    #
    #   A1 horizontal # the ship will occupy A1, A2, A3, A4, and A5
    #   A1 vertical # the ship will occupy A1, B1, C1, D1, and E1
    #   F5 horizontal # the ship will occupy F5, F6, F7, F8, and F9
    #   F5 vertical # the ship will occupy F5, G5, H5, I5, and J5
    #
    # The ship must not fall off the edge of the map.  For example, a carrier placement of 'A8 horizontal' would
    # not leave enough space in the A row to accomidate the carrier since it requires 5 squares.
    #
    # Ships may not overlap with other ships.  For example a carrier placement of 'A1 horizontal' and a submarine
    # placement of 'A1 vertical' would be invalid because bothe ships are trying to occupy the square A1.
    #
    # Invalid ship placements will result in disqualification of the player.
    #
    def carrier_placement
      return "G1 horizontal"
    end

    # Returns the placement of the battleship. A battleship consumes 4 squares.
    #
    # See carrier_placement for details on ship placement
    #
    def battleship_placement
      return "F8 vertical"
    end

    # Returns the placement of the destroyer. A destroyer consumes 3 squares.
    #
    # See carrier_placement for details on ship placement
    #
    def destroyer_placement
      return "C5 vertical"
    end

    # Returns the placement of the submarine. A submarine consumes 3 squares.
    #
    # See carrier_placement for details on ship placement
    #
    def submarine_placement
      return "B7 horizontal"
    end

    # Returns the placement of the patrolship. A patrolship consumes 2 squares.
    #
    # See carrier_placement for details on ship placement
    #
    def patrolship_placement
      return "I3 horizontal"
    end

    # Returns the coordinates of the players next target.  This method will be called once per turn.  The player
    # should return target coordinates as a string in the form of:
    #
    #   "#{ROW}#{COL}"
    #
    # eg
    #
    #   A1 # the square in Row A and Column 1
    #   F5 # the square in Row F and Column 5
    #
    # Since the map contains only 10 rows and 10 columns, the ROW should be A, B, C, D, E, F, G H, I, or J. And the
    # COL should be 1, 2, 3, 4, 5, 6, 7, 8, 9, or 10
    #
    # Returning coordinates outside the range or in an invalid format will result in the players disqualification.
    #
    # It is illegal to target a sector more than once.  Doing so will also result in disqualification.
    #
    def next_target
      target = target_for_current_shot
      @shots_taken += 1
      return target
    end

    # target_result will be called by the system after a call to next_target.  The paramters supplied inform the player
    # of the results of the target.
    #
    #   coordinates : string. The coordinates targeted.  It will be the same value returned by the previous call to next_target
    #   was_hit     : boolean.  true if the target was occupied by a ship.  false otherwise.
    #   ship_sunk   : symbol.  nil if the target did not result in the sinking of a ship.  If the target did result in
    #     in the sinking of a ship, the ship type is supplied (:carrier, :battleship, :destroyer, :submarine, :patrolship).
    #
    # An intelligent player will use the information to better play the game.  For example, if the result indicates a
    # hit, a player my choose to target neighboring squares to hit and sink the remainder of the ship.
    #
    def target_result(coordinates, was_hit, ship_sunk)
      @grid.set(@last_r, @last_c, ship_sunk || (was_hit ? :hit : :miss))
      if ship_sunk
        @ships_left -= [ship_sunk]
        # try to mark all the hits with ship type
        DIRECTIONS.each{|y, x|
          all_hits = true
          (1..(SHIP_TYPES[ship_sunk]-1)).each{|p|
            r = @last_r + y * p
            c = @last_c + x * p
            all_hits = false unless @grid.valid_target?(r, c) && @grid.get(r, c) == :hit
          }
          if all_hits
            (1..(SHIP_TYPES[ship_sunk]-1)).each{|p|
              r = @last_r + y * p
              c = @last_c + x * p
              @grid.set(r, c, ship_sunk)
            }
            break
          end
        }
      end
    end

    # enemy_targeting is called by the system to inform a player of their apponents move.  When the opponent targets
    # a square, this method is called with the coordinates.
    #
    # Players may use this information to understand an opponents targeting strategy and place ships differently
    # in subsequent games.
    #
    def enemy_targeting(coordinates)
    end

    # Called by the system at the end of a game to inform the player of the results.
    #
    #   result  : 1 of 3 possible values (:victory, :defeate, :disqualified)
    #   disqualification_reason : nil unless the game ended as the result of a disqualification.  In the event of a
    #     disqualification, this paramter will hold a string description of the reason for disqualification.  Both
    #     players will be informed of the reason.
    #
    #   :victory # indicates the player won the game
    #   :defeat # indicates the player lost the game
    #   :disqualified # indicates the player was disqualified
    #
    def game_over(result, disqualification_reason=nil)
    end

    # Non API methods #####################################

    attr_reader :opponent, :targets, :enemy_targeted_sectors, :result, :disqualification_reason #:nodoc:

    def initialize #:nodoc:
      reset
    end

    private ###############################################

    SHIP_TYPES = {:carrier => 5, :battleship => 4, :destroyer => 3,
      :submarine => 3, :patrolship => 2}
    DIRECTIONS = [[-1, 0], [0, 1], [1, 0], [0, -1]]
    
    def reset
      @shots_taken = 0
      @grid = Grid.new
      @ships_left = SHIP_TYPES.keys
      @ships_dead = []
    end

    ROWS = %w{ A B C D E F G H I J }
    def target_for_current_shot
      # r, c = destroy_hit_ships || find_ships || random_shot
      score_grid
      @last_r, @last_c = pick_best
      coord_to_target(@last_r, @last_c)
    end
    
    def coord_to_target(r, c)
      "#{ROWS[r]}#{c + 1}"
    end
    
    def score_grid
      n = smallest_ship_size
      @grid_score = Grid.new
      @grid_score.each_cell{|row, col|
        @grid_score.set(row, col, 0)
        # - 1000 if already shot at
        if @grid.get(row, col)
          @grid_score.dec(row, col, 1000)
        else
          # + 100 if there's a damaged ship nearby
          DIRECTIONS.each{|dir_y, dir_x|
            r = row + dir_y
            c = col + dir_x
            if @grid.valid_target?(r, c) && @grid.get(r, c) == :hit
              @grid_score.inc(row, col, 100)
              r = row + dir_y * 2
              c = col + dir_x * 2
              @grid_score.inc(row, col, 200) if @grid.valid_target?(r, c) && @grid.get(r, c) == :hit
            end
          }
          
          # - 10 if there's a guess in a direction within n - 1
          DIRECTIONS.each{|dir_y, dir_x|
            has_close_guess = false
            (1..n-1).each{|multiplier|
              r = row + (dir_y * multiplier)
              c = col + (dir_x * multiplier)
              has_close_guess = true if @grid.valid_target?(r, c) && @grid.get(r, c)
            }
            @grid_score.dec(row, col, 10) if has_close_guess
          }
        end
      }
    end
    
    def pick_best
      best_score = -999
      best_coords = [[0, 0]]
      @grid_score.each_cell{|row, col, cell|
        if cell > best_score
          best_score = cell
          best_coords = [[row, col]]
        elsif cell == best_score
          best_coords << [row, col]
        end
      }
      best_coords[rand(best_coords.size)]
    end
    
    def smallest_ship_size
      # the size of the smallest ship left
      @ships_left.inject(5) {|smallest, ship|
        smallest = (SHIP_TYPES[ship] < smallest) ? SHIP_TYPES[ship] : smallest
      }
    end

    def random_shot
      begin
        r, c = rand(10), rand(10)
      end until !@grid[r][c]
      [r, c]
    end
  end

  class Grid
    def initialize
      reset
    end
    
    def reset
      @grid = Array.new(10)
      @grid.each_with_index{|a, i| @grid[i] = Array.new(10) }
    end
    
    def valid_target?(row, col)
      (0..9).include?(row) && (0..9).include?(col)
    end
    
    def each_cell
      (0..9).each{|row|
        (0..9).each{|col|
          yield row, col, @grid[row][col]
        }
      }
    end
    
    def get(row, col)
      @grid[row][col]
    end
    
    def [](row, col)
      @grid[row][col]
    end

    def set(row, col, val)
      @grid[row][col] = val
    end
    
    def dec(row, col, val = 1)
      @grid[row][col] -= val
    end

    def inc(row, col, val = 1)
      @grid[row][col] += val
    end
  end
end