!     Estimate the value of Pi via Monte Carlo

      program pi_omp
      use, intrinsic :: iso_fortran_env
      implicit none

      integer, parameter :: maximumCommandLength = 32

      character(len=maximumCommandLength) :: commandArgument
 
      integer :: commandCount
      integer :: commandNumber
      integer :: commandLength
      integer :: commandStatus
      integer :: sampleCount
      integer :: sampleNumber
      integer :: samplesInside
      integer :: randomSeedSize
      integer :: ioStatus
      integer :: ompThreadCount
      integer :: ompThreadID

      real :: x
      real :: y
      real :: r
      real :: pi

      integer, allocatable, dimension(:) :: randomSeed

      integer :: omp_get_num_threads
      integer :: omp_get_thread_num

      commandCount = command_argument_count()
      if (commandCount > 0) then
         commandNumber = 1
         do while (commandNumber <= commandCount)
            call get_command_argument(commandNumber, commandArgument, &
                                      commandLength, commandStatus)
            commandNumber = commandNumber + 1
            select case(commandArgument)
               case('-s', '--samples')
                  call get_command_argument(commandNumber, &
                     & commandArgument, commandLength, &
                     & commandStatus)
                  commandNumber = commandNumber + 1
                  read(unit=commandArgument, fmt=*) sampleCount

               case default
                  write(unit=error_unit, fmt=*) &
                     'ERROR: Unrecognized command-line argument.'

            end select
         end do

      else if (commandCount == 0) then
         write(unit=error_unit, fmt=*) &
            'ERROR: No command-line arguments specified.'

      else
         write(unit = error_unit, fmt = *) &
            'ERROR: command_argument_count() returned a negative value.'

      end if

      call random_seed(size=randomSeedSize)
      allocate(randomSeed(randomSeedSize))
      open(unit=999, file="/dev/urandom", access="stream", &
         & form="unformatted", action="read", status="old", &
         & iostat=ioStatus)
         if (ioStatus == 0) then
            read(unit=999,iostat=ioStatus) randomSeed
            close(unit=999)
         end if
      call random_seed(put=randomSeed)

      samplesInside = 0

!$omp parallel default(private), shared(sampleCount,samplesInside)
      ompThreadID = omp_get_thread_num()
!$omp do schedule(static), reduction(+:samplesInside)
      do sampleNumber = 1, sampleCount
         call random_number(x)
         call random_number(y)
         r = sqrt(x**2 + y**2)
         if (r <= 1.0) then
            samplesInside = samplesInside + 1
         end if
      end do
!$omp end do
!$omp end parallel

      pi = 4 * real(samplesInside) / real(sampleCount)
      write(unit=output_unit, fmt=*) pi

      stop
      end program
