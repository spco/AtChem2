
module argparse_mod

  type flag
    character(100) :: flag_switch
    character(200) :: flag_help
  end type flag

  type(flag), parameter :: valid_flags(10) = &
              [ flag('--help', 'Displays this help message.'), &
                flag('--model', 'The base directory of the model.'), &
                flag('--output', 'The destination directory for output.'), &
                flag('--configuration', 'The directory of the model configuration.'), &
                flag('--constraints', 'The base directory of constraints. ' // &
                                      'This typically contains 3 subdirectories: environment, photolysis, and species.'), &
                flag('--env_constraints', 'The directory containing environment constraints data.'), &
                flag('--photo_constraints', 'The directory containing photolysis constraints data.'), &
                flag('--spec_constraints', 'The directory containing species constraints data.'), &
                flag('--mcm', 'The directory containing the MCM data.'), &
                flag('--shared_lib', 'The full path to the mechanism.so shared library ' // &
                                     '(generated by ./tools/build.sh).') ]

contains

  subroutine print_help()
    implicit none

    integer i

    write(*,*) new_line('A')//' This is the help message.'

    write(*, '(A)', advance='no') ' Usage: ./atchem '
    write(*, '(3A)', advance='no') '[', trim(valid_flags(1)%flag_switch), '] '
    do i=2, size(valid_flags)
      write(*, '(5A)', advance='no') '[', trim(valid_flags(i)%flag_switch), '=', &
                                    trim(valid_flags(i)%flag_switch(3:))//'_dir', '] '
    end do

    write(*,*) new_line('A')//' Possible input flags are: '
    do i=1, size(valid_flags)
      write(*,*) trim(valid_flags(i)%flag_switch)
      write(*,*) '     ', valid_flags(i)%flag_help//new_line('A')
    end do

    write(*,*) 'In essence, the directories default to sit in the following tree. '
    write(*,*) 'Modification via the input parameters cascades to lower directories, but is overwritten by explicit input.'
    write(*,*)
    write(*,*) '                                 model_dir                                          mcm_dir        shared_library'
    write(*,*) '                                      | '
    write(*,*) '     +--------------------------------+--------------------------+'
    write(*,*) '     |                                |                          |'
    write(*,*) ' output_dir                     constraints_dir           configuration_dir'
    write(*,*) '                                                                 |'
    write(*,*) '                                        +------------------------+----------------------+'
    write(*,*) '                                        |                        |                      |'
    write(*,*) '                              env_constraints_dir   photo_constraints_dir  species_constraints_dir'
    write(*,*)
  end subroutine print_help

  ! split a string into 2 either side of a delimiter token
  subroutine split_string( instring, string1, string2, delim )
    implicit none
    character(100) :: instring
    character :: delim
    character(100), intent(out) :: string1, string2
    integer :: index

    instring = trim(instring)

    index = scan(instring, delim)
    if ( index /= 0 ) then
      if ( index == 1 ) then
        string1 = ''
        string2 = instring(2:)
      else if ( index == len(instring) ) then
        string1 = instring(1:index-1)
        string2 = ''
      else
        string1 = instring(1:index-1)
        string2 = instring(index+1:)
      end if
    else
      if ( instring /= '--help' ) then
        write(*,*) 'delimiter not found'
      end if
      string1 = instring
      string2 = ''
    end if

  end subroutine split_string


  subroutine check_name_value_pair_validity( name, value, name_valid, value_valid )
    implicit none

    character(len=*), intent(in) :: name, value
    logical, intent(out) :: name_valid, value_valid

    name_valid = .true.
    ! Check validity of name
    if ( index(name, '--', back=.true.) /= 1 ) then
      if ( index(name, '--', back=.true.) == 0 ) then
        write(*,*) '-- does not occur in "', trim(name), '"'
        name_valid = .false.
      else
        write(*,*) 'name "', trim(name), '" is not valid - too many or incorrectly placed --s'
        name_valid = .false.
      end if
    end if

    value_valid = .true.
    ! Check validity of value - just check it hasn't got any spaces
    ! TODO: note that this can't really fail unless empty
    if ( len(trim(value)) == 0) then
      if ( trim(name) /= '--help' ) then
        write(*,*) 'flag "', trim(name), '" has no associated value supplied.'
        value_valid = .false.
      end if
    end if
    if ( index(trim(value), ' ') /= 0 ) then
      write(*,*) 'value "', value, '" is invalid as it contains a space'
      value_valid = .false.
    end if

  end subroutine check_name_value_pair_validity


  function array_contains( array, value ) result ( index )
    implicit none
    character(len=*), intent(in) :: array(:), value
    integer :: index
    integer :: i

    if ( size(array) > 0 ) then
      do i=1, size(array)
        if ( trim(array(i)) == trim(value) ) then
          index = i
          return
        end if
      end do
    end if
    index = 0

    return
  end function array_contains


  function flag_array_contains( array, value ) result ( index )
    implicit none
    type(flag), intent(in) :: array(:)
    character(len=*), intent(in) :: value
    integer :: index
    integer :: i

    if ( size(array) > 0 ) then
      do i=1, size(array)
        if ( trim(array(i)%flag_switch) == trim(value) ) then
          index = i
          return
        end if
      end do
    end if
    index = 0

    return
  end function flag_array_contains


  function read_value_or_default( output_name, default, names, values ) result ( out )
    implicit none
    character(len=*), intent(in) :: output_name, default, names(:), values(:)
    character(len=100) :: out
    integer :: loc

    loc = array_contains(names, output_name)

    if ( loc /= 0 ) then
      out = trim(values(loc))
    else
      out = trim(default)
    end if

  end function  read_value_or_default

  ! -----------------------------------------------------------------
  ! Read in command line argument to direct output files to a given
  ! directory
  subroutine get_and_set_directories_from_command_arguments()
    use, intrinsic :: iso_fortran_env, only : stderr => error_unit
    use types_mod
    use directories_mod
    implicit none

    integer(kind=QI) :: cmd_arg_count, i
    character(len=100), allocatable :: input_strings(:), names(:), values(:)
    logical, allocatable :: names_valid(:), values_valid(:)
    logical :: all_valid

    all_valid = .true.
    ! count possible arguments
    cmd_arg_count = command_argument_count()
    ! read in possible arguments
    allocate( input_strings(cmd_arg_count), names(cmd_arg_count), values(cmd_arg_count), &
              names_valid(cmd_arg_count), values_valid(cmd_arg_count) )

    if ( cmd_arg_count > 0 ) then
      do i=1, cmd_arg_count
        call get_command_argument( i, input_strings(i) )
      end do

      ! parse arguments and check for naive validity
      do i=1, cmd_arg_count
        call split_string( input_strings(i), names(i), values(i), '=' )
        call check_name_value_pair_validity( names(i), values(i), names_valid(i), values_valid(i) )
        if ( names_valid(i) .neqv. .true. ) then
          all_valid = .false.
          write(*,*) 'supplied flag "', trim(names(i)), '" is not valid when paired with value "', trim(values(i)), '"'
        end if
        if ( values_valid(i) .neqv. .true. ) then
          all_valid = .false.
          write(*,*) 'value "', trim(values(i)), '" is not valid when paired with name "', trim(names(i)), '"'
        end if
        if ( flag_array_contains(valid_flags, names(i)) == 0 ) then
          all_valid = .false.
          write(*,*) 'supplied flag "', trim(names(i)) , '" is not a valid flag.'
        end if
      end do
    end if

    ! report back on validity
    if (.not. all_valid) then
      call print_help()
      stop
    end if

    ! check for existence of --help flag - if it exists, ignore all others, and print the help text
    if ( array_contains(names, valid_flags(1)%flag_switch) /= 0 ) then
      write(*,*) '--help flag supplied'
      call print_help()
      stop
    end if

    ! set each of the directory locations from the command line, following the defined logic for defaults if some are not supplied
    model_dir             = read_value_or_default( valid_flags(2)%flag_switch, 'model', names, values )
    output_dir            = read_value_or_default( valid_flags(3)%flag_switch, trim(model_dir)//'/output', names, values )
    reactionRates_dir     = trim(output_dir)//'/reactionRates'
    configuration_dir     = read_value_or_default( valid_flags(4)%flag_switch, trim(model_dir)//'/configuration', names, values )
    constraints_dir       = read_value_or_default( valid_flags(5)%flag_switch, trim(model_dir)//'/constraints', names, values )
    env_constraints_dir  = read_value_or_default( valid_flags(6)%flag_switch, trim(constraints_dir)//'/environment', names, values )
    photo_constraints_dir = read_value_or_default( valid_flags(7)%flag_switch, trim(constraints_dir)//'/photolysis', names, values )
    spec_constraints_dir  = read_value_or_default( valid_flags(8)%flag_switch, trim(constraints_dir)//'/species', names, values )
    mcm_dir               = read_value_or_default( valid_flags(9)%flag_switch, 'mcm', names, values )
    shared_library        = read_value_or_default( valid_flags(10)%flag_switch, 'model/configuration/mechanism.so', names, values )

    write (*, '(2A)') ' Model dir is: ', trim( model_dir )
    write (*, '(2A)') ' Output dir is: ', trim( output_dir )
    write (*, '(2A)') ' Configuration dir is: ', trim( configuration_dir )
    write (*, '(2A)') ' MCM dir is: ', trim( mcm_dir )
    write (*, '(2A)') ' Species Constraints dir is: ', trim( spec_constraints_dir )
    write (*, '(2A)') ' Environment Constraints dir is: ', trim( env_constraints_dir )
    write (*, '(2A)') ' Photolysis Constraints dir is: ', trim( photo_constraints_dir )
    write (*, '(2A)') ' Shared library is: ', trim( shared_library )

  end subroutine get_and_set_directories_from_command_arguments

end module argparse_mod
